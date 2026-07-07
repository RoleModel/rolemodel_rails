# frozen_string_literal: true

module Rolemodel
  class SimpleFormGenerator < GeneratorBase
    source_root File.expand_path('templates', __dir__)

    class_option :tailored_select, type: :boolean, default: false,
                                   desc: 'Install the tailored_select experimental component input'

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

    def install_tailored_select
      return unless options.tailored_select?

      # The tailored_select generator owns the input template and installs it
      # here because simple_form is now present.
      generate 'rolemodel:tailored_select'
    end
  end
end
