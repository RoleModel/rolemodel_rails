require_relative '../../bundler_helpers'

module Rolemodel
  class WebpackerGenerator < Rails::Generators::Base
    include Rolemodel::BundlerHelpers
    source_root File.expand_path('templates', __dir__)

    def create_node_version
      node_version = '10.16.0'
      create_file ".node-version", node_version
      raise "Don't have node version #{node_version} installed. Fix it.\nRun: `nodenv install #{node_version}`" unless system 'node --version'
      raise "Don't have yarn installed. Fix it.\nRun: `npm install -g yarn`" unless system 'yarn --version'
    end

    def install_webpacker
      gem 'webpacker'
      run_bundle
      rake('webpacker:install')

      say 'Add the content_security_policy config for webpack-dev-server'
      template 'content_security_policy.rb', 'config/initializers/content_security_policy.rb'
    end

    def install_react
      if yes? 'Does this project need react? [Yn]'
        @using_react = true
        rake('webpacker:install:react')
        remove_file 'app/javascript/packs/hello_react.jsx'
        gem 'react-rails'
        run_bundle
        run 'yarn add prop-types'
        generate('react:install')
      end
    end

    def install_jest
      @using_cond = false
      say 'Installing Jest'
      run 'yarn add -D jest babel-jest'
      template 'jest.config.js.erb', 'jest.config.js'
      template 'FilePathMock.js', 'spec/javascript/support/FilePathMock.js'

      if @using_react
        say 'Installing Enzyme'
        run 'yarn add -D jest-enzyme enzyme enzyme-adapter-react-16'
        template 'enzyme.js', 'spec/javascript/support/enzyme.js'
      end
    end

    def setup_tasks
      say 'Adding package.json test scripts'

      if @using_cond
        yarn_scripts = {
          "test" => "bundle exec rake javascript_tests",
          "test_view" => "NODE_ENV=test jest --watch",
          "test_view_ci" => "NODE_ENV=test jest",
          "test_shared" => "NODE_ENV=test NODE_PATH=\"./node_modules:./app/javascript:$NODE_PATH\" jasmine"
        }
      else
        yarn_scripts = {
          "test" => "jest --watch",
          "test_ci" => "jest",
          "test_debug" => "CI=1 node --inspect-brk ./node_modules/.bin/jest --runInBand --no-cache --env=jsdom",
          "eslint" => "eslint 'app/**/*.js' 'spec/**/*.js'",
          "stylelint" => "stylelint app/javascript/stylesheets/**/*.{css,scss}"
        }
      end

      json = JSON.parse(File.read('package.json'))
      json['scripts'] = yarn_scripts
      File.write('package.json', JSON.pretty_generate(json))

      say 'Add Rake task'
      template 'javascript_tests.rake.erb', 'lib/tasks/javascript_tests.rake'
      append_to_file 'Rakefile', "\ntask default: [ 'spec', 'javascript_tests' ]"
    end
  end
end
