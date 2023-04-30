module Rolemodel
  class WebpackGenerator < Rails::Generators::Base
    source_root File.expand_path('templates', __dir__)

    NODE_VERSION = '18.15.0'.freeze

    DEV_DEPS = %w[
      @honeybadger-io/webpack
      @honeybadger-io/js
      esbuild
      esbuild-loader
      webpack
      webpack-cli
    ]

    POSTCSS_PKGS = %w[
      @csstools/postcss-sass
      postcss
      postcss-loader
      postcss-preset-env
      postcss-scss
    ]

    WEBPACK_CSS_PKGS = %w[
      css-loader
      css-minimizer-webpack-plugin
      mini-css-extract-plugin
      webpack-remove-empty-scripts
    ]

    def ensure_node_version
      say "Ensuring Node version #{set_color(NODE_VERSION, :yellow)} is installed via nodenv"

      run 'brew update && brew install nodenv node-build'
      run "nodenv install #{NODE_VERSION}"
    end

    def force_node_to_use_es_modules
      say 'Configuring project to use ES Modules instead of CommonJS'

      run 'npm pkg set type=module'
    end

    def remove_obsolete_javascript_dependencies
      say 'Removing webpack & webpack-cli from package.json dependencies'

      run 'yarn remove webpack webpack-cli'
    end

    def add_npm_packages
      say 'Adding new dev dependencies to package.json'

      dependencies = DEV_DEPS + POSTCSS_PKGS + WEBPACK_CSS_PKGS
      run "yarn add --dev #{dependencies.join(' ')}"
    end

    def honeybadger_setup
      say 'Setting up Honeybadger for JS error reporting'

      append_to_file 'app/javascript/application.js' do
        <<~JS
          import Honeybadger from '@honeybadger-io/js'

          if (process.env.RAILS_ENV === 'production') {
            Honeybadger.configure({
              apiKey: process.env.HONEYBADGER_API_KEY,
              environment: process.env.HONEYBADGER_ENV,
              revision: process.env.SOURCE_VERSION
            })
          }
        JS
      end
    end

    def replace_css_entrypoint_with_scss
      say 'Replacing CSS entrypoint file with SCSS version'

      remove_file 'app/assets/stylesheets/application.css'
      template 'app/assets/stylesheets/application.scss'
    end

    def add_webpack_config
      say 'Copying PostCSS & Webpack config files'

      template 'postcss.config.cjs'
      template 'webpack.config.js'
    end
  end
end
