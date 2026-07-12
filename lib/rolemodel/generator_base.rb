# frozen_string_literal: true

require 'rails/generators'
require 'rails/generators/bundle_helper'
require_relative 'replace_content_helper'
require_relative 'registry'

module Rolemodel
  # Shared base class for all rolemodel_rails generators: common helpers plus
  # the registry recording seam that runs after every successful invocation.
  class GeneratorBase < ::Rails::Generators::Base
    include ::Rails::Generators::BundleHelper, ReplaceContentHelper

    # Exempts a generator from registry recording (composites, hook
    # sub-generators, the seeding generator). Inherited by subclasses.
    def self.skip_registry_entry!
      @skip_registry_entry = true
    end

    def self.skip_registry_entry?
      if instance_variable_defined?(:@skip_registry_entry)
        @skip_registry_entry
      else
        superclass.respond_to?(:skip_registry_entry?) && superclass.skip_registry_entry?
      end
    end

    # Declares an optional coupling with another generator: a boolean hook_for
    # sharing +hook_key+ with the other side, defaulting to whether +with+ is
    # recorded in the app's registry. The framework provides the rest: the
    # --<hook-key>/--no-<hook-key> switch pair, the rolemodel:<hook_key>
    # sub-generator lookup, and config-key precedence (an explicit
    # `g.rolemodel <hook_key>: ...` entry overrides the computed default).
    #
    # The default resolves at class-DEFINITION time. That is correct because
    # generator classes load after Rails::Generators.configure! in real runs —
    # which is also why a coupling-declaring generator must never be
    # eagerly required from the engine's generators block.
    #
    # Declaration position matters: hook invocations run where they are
    # declared, so coupling_hook belongs AFTER the action methods it depends
    # on — the wiring sub-generator must find the files those actions create.
    def self.coupling_hook(hook_key, with:)
      hook_for hook_key, type: :boolean, default: Registry.recorded?(with)

      skip_note = "Skipping #{hook_key} — #{with} is not recorded in #{Registry::INITIALIZER_PATH}. " \
                  "Re-run this generator after installing rolemodel:#{with}, " \
                  "or pass --#{hook_key.to_s.tr('_', '-')}."

      # Public on purpose: Thor registers it as the command immediately after
      # the hook invocation, so the skip note prints exactly where the hook
      # would have run. When the hook fires, its own invoke status line is
      # the user-facing output and this stays silent.
      class_eval <<~RUBY, __FILE__, __LINE__ + 1
        def #{hook_key}_skip_note
          say #{skip_note.inspect}, :yellow unless options[:#{hook_key}]
        end
      RUBY
    end

    # Declares a hard prerequisite: the generator aborts (via
    # ensure_required_generators below) before any of its actions run unless
    # +key+ is recorded in the app's registry. Deliberately exposes no CLI
    # switch — hard prerequisites are not bypassable per-invocation; the
    # remedies are installing the missing generator or seeding the registry.
    def self.requires_generator(key)
      @required_generator_keys = required_generator_keys + [key.to_sym]
    end

    # Accumulated prerequisite keys, inherited by subclasses.
    def self.required_generator_keys
      if instance_variable_defined?(:@required_generator_keys)
        @required_generator_keys
      else
        superclass.respond_to?(:required_generator_keys) ? superclass.required_generator_keys : []
      end
    end

    # Thor's method_added turns public instance methods into commands, and
    # invoke_all is NOT in THOR_RESERVED_WORDS — without no_commands this
    # override would itself become a command and recurse.
    no_commands do
      # The registry recording seam: once a run completes without raising,
      # record this generator in the consuming app's registry initializer
      # (or remove the entry under `rails destroy`). An exception during the
      # run propagates and records nothing.
      def invoke_all
        super.tap { update_registry_entry }
      end
    end

    # The requires_generator guard. Public on purpose: Thor turns it into a
    # command, and because inherited commands run before subclass commands it
    # executes before any subclass action for every generator. It shows up in
    # every generator's command list, so the name must say what it does —
    # and nothing else on GeneratorBase may be public.
    def ensure_required_generators
      return unless behavior == :invoke # rails destroy teardown is never blocked

      missing = self.class.required_generator_keys.reject { |key| Registry.recorded?(key) }
      return if missing.empty?

      raise Thor::Error, <<~MESSAGE
        #{self.class.namespace} requires #{missing.join(', ')} to be installed first,
        but no entry is recorded in #{Registry::INITIALIZER_PATH}.
        Install the missing generator (bin/rails generate rolemodel:#{missing.first}) and re-run,
        or run bin/rails generate rolemodel:registry to seed the registry in an existing app.
      MESSAGE
    end

    private

    # based on https://github.com/rails/rails/blob/main/railties/lib/rails/generators/app_base.rb#L713
    def run_bundle
      bundle_command("install --quiet", "BUNDLE_IGNORE_MESSAGES" => "1")
    end

    # Enable Corepack and pin the project to Yarn 4+ (instead of the classic
    # Yarn 1.22). Idempotent, so any generator can call it before running a
    # `yarn` command to guarantee the modern toolchain is in place.
    def ensure_yarn
      return if @yarn_ensured

      run 'corepack enable'

      unless File.exist?(File.expand_path('package.json', destination_root))
        create_file 'package.json', JSON.pretty_generate({}) + "\n"
      end

      # Configure the node-modules linker so webpack, Playwright, and the Rails
      # asset pipeline keep working (Yarn 4 defaults to Plug'n'Play otherwise).
      create_file '.yarnrc.yml', "nodeLinker: node-modules\n", force: true

      pin_yarn_version
      ignore_yarn_install_state

      @yarn_ensured = true
    end

    def pin_yarn_version
      modify_json_file('package.json') do |hash|
        hash['packageManager'] = "yarn@#{YARN_VERSION}"
        hash
      end
    end

    def ignore_yarn_install_state
      gitignore = File.expand_path('.gitignore', destination_root)
      return create_file '.gitignore', "/.yarn/install-state.gz\n" unless File.exist?(gitignore)
      return if File.read(gitignore).include?('/.yarn/install-state.gz')

      append_to_file '.gitignore', "\n/.yarn/install-state.gz\n"
    end

    # Single source of truth for wiring the Sentry webpack plugin into
    # webpack.config.js. Shared by the webpack generator (which owns the config
    # file) and the sentry generator (for standalone runs). Idempotent and a
    # no-op if there's no webpack.config.js or it's already wired.
    def wire_sentry_into_webpack
      config = File.expand_path('webpack.config.js', destination_root)
      return unless File.exist?(config)
      return if File.read(config).include?('@sentry/webpack-plugin')

      say 'Wiring Sentry into webpack.config.js', :green

      inject_into_file 'webpack.config.js',
                       "import { sentryWebpackPlugin } from '@sentry/webpack-plugin'\n",
                       after: "import CssMinimizerPlugin from 'css-minimizer-webpack-plugin'\n"

      inject_into_file 'webpack.config.js', after: "'process.env.RAILS_ENV': JSON.stringify(process.env.RAILS_ENV),\n" do
        <<-JS
      'process.env.SENTRY_DSN': JSON.stringify(process.env.SENTRY_DSN),
      'process.env.SENTRY_ENVIRONMENT': JSON.stringify(process.env.SENTRY_ENVIRONMENT),
      'process.env.SENTRY_AUTH_TOKEN': JSON.stringify(process.env.SENTRY_AUTH_TOKEN),
        JS
      end

      gsub_file 'webpack.config.js', "    })\n  ].filter(Boolean)", <<-JS.chomp
    }),

    // Upload source maps to Sentry in production for easier debugging
    mode === 'production' &&
      !process.env.CI &&
      sentryWebpackPlugin({
        authToken: process.env.SENTRY_AUTH_TOKEN,
        org: 'rolemodel-software',
        project: '#{Rails.application.name}',
        telemetry: false,
        applicationKey: 'app-frontend'
      })
  ].filter(Boolean)
      JS
    end

    def sentry_app_name
      Rails.application.class.module_parent_name.underscore
    end

    def update_registry_entry
      return if self.class.skip_registry_entry?

      if behavior == :revoke
        Registry.remove(Registry.key_for(self.class), destination_root: destination_root)
      elsif behavior == :invoke && !options[:pretend]
        record_registry_entry
      end
    end

    def record_registry_entry
      key = Registry.key_for(self.class)

      case Registry.record(key, destination_root: destination_root)
      when :recorded
        say "Recorded #{key} in #{Registry::INITIALIZER_PATH}", :green
      when :skipped_opt_out
        say "Not recording #{key} — explicitly set to false in #{Registry::INITIALIZER_PATH}", :yellow
      end
    end
  end
end
