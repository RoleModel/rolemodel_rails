require_relative '../../bundler_helpers'

module Rolemodel
  class SimpleFormGenerator < Rails::Generators::Base
    include Rolemodel::BundlerHelpers
    source_root File.expand_path('templates', __dir__)

    def add_gem
      gem 'simple_form'
      run_bundle
    end

    def add_files
      directory 'app/inputs'
      copy_file 'config/initializers/simple_form.rb'
      copy_file 'config/locales/simple_form.en.yml'
      copy_file 'lib/templates/slim/scaffold/_form.html.slim'
    end
  end
end
