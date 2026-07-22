module Rolemodel
  module Turbo
    class FormGenerator < GeneratorBase
      source_root File.expand_path('templates', __dir__)

      def add_rails_request_package
        say 'Installing @rails/request.js package', :green

        ensure_yarn
        run 'yarn add @rails/request.js'
      end

      def add_stimulus_controller
        say 'Adding Turbo Form Stimulus Controller', :green

        directory 'app/javascript/controllers'

        rails_command 'stimulus:manifest:update'
      end

      def add_system_spec_helper
        say 'Adding Turbo Form System Spec Helper', :green

        directory 'spec/support/helpers'
      end
    end
  end
end

