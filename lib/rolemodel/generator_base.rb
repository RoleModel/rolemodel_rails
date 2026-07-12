# frozen_string_literal: true

require 'rails/generators'
require 'rails/generators/bundle_helper'
require_relative 'replace_content_helper'

module Rolemodel
  class GeneratorBase < ::Rails::Generators::Base
    include ::Rails::Generators::BundleHelper, ReplaceContentHelper

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
  end
end
