# frozen_string_literal: true

module Rolemodel
  class SimpleFormGenerator < GeneratorBase
    source_root File.expand_path('templates', __dir__)

    def add_gem
      Bundler.with_unbundled_env do
        bundle_command 'add simple_form'
      end
    end

    def add_files
      directory 'app/inputs'
      directory 'lib/templates/slim/scaffold'
      copy_file 'config/initializers/simple_form.rb'
      copy_file 'config/locales/simple_form.en.yml'
    end

    def add_tailored_select_input
      return unless yes?('Would you like to include the tailored_select custom input?')

      copy_file 'optional/tailored_select_input.rb', 'app/inputs/tailored_select_input.rb'
    end
  end
end
