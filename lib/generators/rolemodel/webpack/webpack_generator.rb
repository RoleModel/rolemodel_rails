module Rolemodel
  class WebpackGenerator < GeneratorBase
    source_root File.expand_path('templates', __dir__)

    DEV_DEPS = %w[
      @honeybadger-io/webpack
      @honeybadger-io/js
      esbuild
      esbuild-loader
      webpack
      webpack-cli
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

      dependencies = DEV_DEPS + WEBPACK_CSS_PKGS
      run "yarn add --dev #{dependencies.join(' ')}"
    end

    def honeybadger_setup
      say 'Setting up Honeybadger for JS error reporting', :green

      copy_file 'app/javascript/initializers/honeybadger.js'
      append_to_file 'app/javascript/application.js', <<~JS
        import './initializers/honeybadger'
      JS
    end

    def add_css_entrypoint
      say 'Adding CSS entrypoint file', :green

      copy_file 'app/assets/stylesheets/application.css', force: true
    end

    def add_webpack_config
      say 'Copying Webpack config file', :green

      copy_file 'webpack.config.js', force: true
    end
  end
end
