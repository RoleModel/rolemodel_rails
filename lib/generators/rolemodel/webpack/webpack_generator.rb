module Rolemodel
  class WebpackGenerator < GeneratorBase
    source_root File.expand_path('templates', __dir__)

    DEV_DEPS = %w[
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

    def ensure_no_importmap
      return unless Rails.root.join(destination_root, 'config/importmap.rb').exist?

      remove_file 'config/importmap.rb'
      bundle_command 'remove importmap-rails'
    end

    def ensure_jsbundling
      bundle_command 'add jsbundling-rails'
      run_bundle
    end

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

      yarn_command 'remove webpack webpack-cli'
    end

    def add_npm_packages
      say 'Adding new dev dependencies to package.json', :green

      dependencies = DEV_DEPS + POSTCSS_PKGS + WEBPACK_CSS_PKGS
      yarn_command "add --dev #{dependencies.join(' ')}"
    end

    def add_webpack_config
      say 'Copying PostCSS & Webpack config files', :green

      copy_file 'postcss.config.cjs', force: true
      copy_file 'webpack.config.js', force: true
    end
  end
end
