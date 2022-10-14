module Rolemodel
  class WebpackGenerator < Rails::Generators::Base
    source_root File.expand_path('templates', __dir__)

    def make_project_use_es_modules
      say 'Configuring project to use ES Modules instead of CommonJS'
      json = JSON.parse(File.read('package.json'))
      json['type'] = 'module'
      File.write('package.json', JSON.pretty_generate(json) + "\n")
    end

    def add_npm_packages
      say 'Move Webpack to devDependencies'
      run 'yarn remove webpack webpack-cli'

      say 'Add NPM packages for compiling JS and CSS'
      js_packages = %w[
        @honeybadger-io/webpack
        esbuild
        esbuild-loader
        honeybadger-js
        webpack
        webpack-cli
      ]

      css_packages = [
        # PostCSS related packages
        '@csstools/postcss-sass',
        'postcss',
        'postcss-loader',
        'postcss-preset-env',
        'postcss-scss',

        # Webpack related packages for CSS bundling
        'css-loader',
        'css-minimizer-webpack-plugin',
        'mini-css-extract-plugin',
        'webpack-remove-empty-scripts'
      ]

      all_packages = [*js_packages, *css_packages]

      run "yarn add --dev #{all_packages.join(' ')}"
    end

    def add_webpack_config
      say 'Copying config files'

      remove_file 'app/assets/stylesheets/application.css'
      template 'app/assets/config/manifest.js', 'app/assets/config/manifest.js'
      template 'app/assets/stylesheets/application.scss', 'app/assets/stylesheets/application.scss'

      template 'app/javascript/application.js', 'app/javascript/application.js'
      template 'app/javascript/controllers/index.js', 'app/javascript/controllers/index.js'

      template '.node-version', '.node-version'
      template 'postcss.config.cjs', 'postcss.config.cjs'
      template 'webpack.config.js', 'webpack.config.js'
    end
  end
end
