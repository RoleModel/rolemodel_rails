# frozen_string_literal: true

module Rolemodel
  class SentryGenerator < GeneratorBase
    source_root File.expand_path('templates', __dir__)

    JS_DEPS = %w[
      @sentry/browser
      @sentry/webpack-plugin
    ]

    def install_gem
      say 'Adding sentry-rails gem', :green

      bundle_command 'add sentry-rails'
    end

    def install_profiler_gem
      say 'Adding stackprof gem for Sentry profiling', :green

      # config/initializers/sentry.rb sets profiles_sample_rate; without stackprof
      # the SDK logs a warning on every boot and profiling is silently disabled.
      # stackprof is a native MRI extension, so restrict it to compatible platforms.
      gem 'stackprof', platforms: :ruby
      run_bundle
    end

    def add_ruby_initializer
      say 'Setting up Sentry for Ruby error reporting', :green

      copy_file 'config/initializers/sentry.rb'
    end

    def add_user_context
      say 'Adding Sentry user context to ApplicationController', :green

      inject_into_class 'app/controllers/application_controller.rb', 'ApplicationController',
                        "  before_action :set_sentry_user, if: :user_signed_in?\n"

      inject_into_file 'app/controllers/application_controller.rb', before: /^end\b/ do
        <<-RUBY

  private

  def set_sentry_user
    Sentry.set_user(id: current_user.id)
  end
        RUBY
      end
    end

    def add_js_dependencies
      say 'Adding Sentry JS dependencies to package.json', :green

      ensure_yarn
      run "yarn add --dev #{JS_DEPS.join(' ')}"
    end

    def add_js_initializer
      say 'Setting up Sentry for JS error reporting', :green

      copy_file 'app/javascript/initializers/sentry.js'
      append_to_file 'app/javascript/application.js', <<~JS
        import './initializers/sentry'
      JS
    end

    def configure_webpack
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
        project: '#{app_name}',
        telemetry: false,
        applicationKey: 'app-frontend'
      })
  ].filter(Boolean)
      JS
    end

    def finishing_notes
      say <<~NOTES

        *** Update the sentryWebpackPlugin `project` and `applicationKey` in webpack.config.js,
            and the matching `filterKeys` in app/javascript/initializers/sentry.js, to your Sentry project.

        *** Set the SENTRY_DSN, SENTRY_ENVIRONMENT, and SENTRY_AUTH_TOKEN environment variables.
      NOTES
    end

    private

    def app_name
      Rails.application.class.module_parent_name.underscore
    end
  end
end
