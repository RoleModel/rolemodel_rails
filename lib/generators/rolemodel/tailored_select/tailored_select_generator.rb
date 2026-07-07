# frozen_string_literal: true

module Rolemodel
  class TailoredSelectGenerator < GeneratorBase
    source_root File.expand_path('templates', __dir__)

    def add_tailored_select_package
      say 'Installing Tailored Select package', :green

      ensure_yarn
      run 'yarn add @rolemodel/tailored-select'
    end

    def add_simple_form_input
      return unless simple_form?

      say 'Installing the Tailored Select SimpleForm input', :green

      copy_file 'app/inputs/tailored_select_input.rb'
    end

    private

    def simple_form?
      File.exist?(File.expand_path('config/initializers/simple_form.rb', destination_root))
    end
  end
end
