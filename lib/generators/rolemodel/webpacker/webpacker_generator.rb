require_relative '../../bundler_helpers'

module Rolemodel
  class WebpackerGenerator < Rails::Generators::Base
    include Rolemodel::BundlerHelpers
    source_root File.expand_path('templates', __dir__)

    def create_node_version
      node_version = '12.18.3'
      create_file ".node-version", node_version
      raise "Don't have node version #{node_version} installed. Fix it.\nRun: `nodenv install #{node_version}`" unless system 'node --version'
      raise "Don't have yarn installed. Fix it.\nRun: `npm install -g yarn`" unless system 'yarn --version'
    end

    def install_webpacker_with_react
      gsub_file 'Gemfile', /gem\s+['"]webpacker['"].*/, "gem 'webpacker', '~> 5.1'"
      gem 'webpacker', '~> 5.1' # ensure webpacker is in Gemfile if it wasn't already there
      gem 'react-rails'
      run_bundle
      files = Dir.glob(Pathname(Rolemodel::WebpackerGenerator.source_root).join('generated', '**', '*'))
      files.each do |file|
        next if File.directory?(file)

        source = file.sub(Rolemodel::WebpackerGenerator.source_root + '/', '')
        destination = file.sub(Rolemodel::WebpackerGenerator.source_root + '/generated/', '')
        copy_file source, destination
      end
    end

    def remove_old_config_files
      remove_file '.babelrc'
      remove_file '.postcssrc'
      remove_file 'app/assets/javascript/application.js'
    end

    def run_yarn
      run 'yarn install'
    end

    def configure_csp
      say 'Add the content_security_policy config for webpack-dev-server'
      copy_file 'content_security_policy.rb', 'config/initializers/content_security_policy.rb'
    end

    def add_jest_config
      say 'Add Jest config'
      template 'jest.config.js.erb', 'jest.config.js'
      copy_file 'FilePathMock.js', 'spec/javascript/support/FilePathMock.js'
    end

    def setup_tasks
      say 'Add Rake task'
      template 'javascript_tests.rake.erb', 'lib/tasks/javascript_tests.rake'
      append_to_file 'Rakefile', "\ntask default: [ 'spec', 'javascript_tests' ]"
    end
  end
end
