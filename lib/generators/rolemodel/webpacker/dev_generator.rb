require_relative '../../bundler_helpers'

module Rolemodel
  module Webpacker
    class DevGenerator < Rails::Generators::Base
      include Rolemodel::BundlerHelpers
      source_root File.expand_path('templates', __dir__)

      def install_webpacker
        gem 'webpacker'
        run_bundle
        rake('webpacker:install')
      end

      def install_react
        rake('webpacker:install:react')
        remove_file 'app/javascript/packs/hello_react.jsx'
        gem 'react-rails'
        run_bundle
        run 'yarn add prop-types core-js@3'
        generate('react:install')
      end

      def install_jest
        say 'Installing Jest'
        # TODO move into package.json template
        run 'yarn add -D jest babel-jest'
      end

      def install_rails_js_with_npm
        # TODO as part of moving away from sprockets
        say 'Installing Rails JS dependencies'
        # run 'yarn add @rails/webpacker @rails/ujs @rails/activestorage @rails/actioncable @rails/actiontext turbolinks'
      end

      def setup_tasks
        say 'Adding package.json test scripts'

        yarn_scripts = {
          "test" => "jest --watch",
          "test_ci" => "jest",
          "test_debug" => "CI=1 node --inspect-brk ./node_modules/.bin/jest --runInBand --no-cache --env=jsdom",
          "eslint" => "eslint 'app/**/*.js' 'spec/**/*.js'",
          "stylelint" => "stylelint app/javascript/stylesheets/**/*.{css,scss}"
        }

        json = JSON.parse(File.read('package.json'))
        json['scripts'] = yarn_scripts
        File.write('package.json', JSON.pretty_generate(json) + "\n")
      end
    end
  end
end
