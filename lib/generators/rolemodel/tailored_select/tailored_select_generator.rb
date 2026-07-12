# frozen_string_literal: true

module Rolemodel
  class TailoredSelectGenerator < GeneratorBase
    source_root File.expand_path('templates', __dir__)

    # The simple_form input is only useful once simple_form is installed. Its
    # default reflects whether simple_form is recorded in the app's registry;
    # --simple-form-input / --no-simple-form-input override per invocation, and
    # simple_form's own delegation passes it explicitly (that run records
    # simple_form only at completion, after this child has already run).
    class_option :simple_form_input, type: :boolean, default: Registry.recorded?(:simple_form),
                                     desc: 'Install the tailored_select SimpleForm input'

    def add_tailored_select_package
      say 'Installing Tailored Select package', :green

      ensure_yarn
      run 'yarn add @rolemodel/tailored-select'
    end

    def add_simple_form_input
      unless options.simple_form_input?
        say 'Skipping the Tailored Select SimpleForm input — simple_form is not recorded in ' \
            "#{Registry::INITIALIZER_PATH}. Re-run after rolemodel:simple_form, or pass --simple-form-input.",
            :yellow
        return
      end

      say 'Installing the Tailored Select SimpleForm input', :green

      copy_file 'app/inputs/tailored_select_input.rb'
    end
  end
end
