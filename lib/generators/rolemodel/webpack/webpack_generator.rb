module Rolemodel
  class WebpackGenerator < Rails::Generators::Base
    source_root File.expand_path('templates', __dir__)

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
    ]

    def ensure_node_version
      say "Establish development environment Node version of #{set_color(NODE_VERSION, :yellow)}", :green

      create_file '.node-version', NODE_VERSION, force: true
    end

    def force_node_to_use_es_modules
      say 'Configuring project to use ES Modules instead of CommonJS', :green

      run 'npm pkg set type=module'
    end

    def remove_obsolete_javascript_dependencies
      say 'Removing webpack & webpack-cli from package.json dependencies', :green

      run 'yarn remove webpack webpack-cli'
    end

    def add_npm_packages
      say 'Adding new dev dependencies to package.json', :green

      dependencies = DEV_DEPS + POSTCSS_PKGS + WEBPACK_CSS_PKGS
      run "yarn add --dev #{dependencies.join(' ')}"
    end

    def honeybadger_setup
      say 'Setting up Honeybadger for JS error reporting', :green

      copy_file 'app/javascript/initializers/honeybadger.js'
      append_to_file 'app/javascript/application.js', <<~JS
        import './initializers/honeybadger'
      JS
    end

    def replace_css_entrypoint_with_scss
      say 'Replacing CSS entrypoint file with SCSS version', :green

      remove_file 'app/assets/stylesheets/application.css'
      copy_file 'app/assets/stylesheets/application.scss'
    end

    def add_webpack_config
      say 'Copying PostCSS & Webpack config files', :green

      copy_file 'postcss.config.cjs', force: true
      copy_file 'webpack.config.js', force: true
    end
  end
end
