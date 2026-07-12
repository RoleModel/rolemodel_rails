# frozen_string_literal: true

module Rolemodel
  # Wiring-only hook sub-generator: injects the Sentry webpack plugin into
  # webpack.config.js. It is the shared target of the sentry<->webpack
  # coupling_hook on both the sentry and webpack generators, so the wiring
  # lives in exactly one place regardless of which side is installed second.
  #
  # Exempt from registry recording (it is not an installable generator in its
  # own right) and idempotent: a no-op when there is no webpack.config.js or
  # the plugin is already wired.
  class SentryWebpackGenerator < GeneratorBase
    skip_registry_entry!

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
        project: '#{project_name}',
        telemetry: false,
        applicationKey: 'app-frontend'
      })
  ].filter(Boolean)
      JS
    end

    private

    # Sentry project slug for the webpack plugin. Guarded so the generator is
    # safe to load and run in unbooted contexts (falls back to a placeholder
    # the finishing notes tell the user to replace).
    def project_name
      return 'app-frontend' unless defined?(::Rails) && ::Rails.application

      ::Rails.application.class.module_parent_name.underscore
    end
  end
end
