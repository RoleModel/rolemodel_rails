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
