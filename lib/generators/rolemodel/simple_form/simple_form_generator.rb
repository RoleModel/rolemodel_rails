# frozen_string_literal: true

module Rolemodel
  class SimpleFormGenerator < Rails::Generators::Base
    include BundlerHelpers
    source_root File.expand_path('templates', __dir__)

    def add_gem
      Bundler.with_unbundled_env do
        run 'bundle add simple_form'
      end
    end

    def add_files
      directory 'app/inputs'
      copy_file 'config/initializers/simple_form.rb'
      copy_file 'config/locales/simple_form.en.yml'
      copy_file 'lib/templates/slim/scaffold/_form.html.slim'
    end
  end
end
