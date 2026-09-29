# frozen_string_literal: true

module Rolemodel
  class TomSelectGenerator < GeneratorBase
    source_root File.expand_path('templates', __dir__)

    def add_tom_select_package
      say 'Installing Tom Select package', :green

      yarn_command 'add tom-select'
    end

    def import_stylesheet
      say 'Importing Tom Select stylesheet', :green

      prepend_to_file application_stylesheet_path, <<~CSS
        @import 'tom-select/dist/css/tom-select.css';
      CSS
    end

    def add_stimulus_controller
      say 'Adding Tom Select Stimulus controller', :green

      directory 'app/javascript/controllers'

      rails_command 'stimulus:manifest:update'
    end

    def add_simple_form_inputs
      return unless simple_form?

      say 'Installing the Tom Select SimpleForm inputs', :green

      directory 'app/inputs'
    end

    private

    def simple_form?
      File.exist?(File.expand_path('config/initializers/simple_form.rb', destination_root))
    end
  end
end
