module Rolemodel
  module Turbo
    class ReadyGenerator < ::Rolemodel::GeneratorBase
      source_root File.expand_path('templates', __dir__)

      def javascript_entrypoint
        say 'generating & importing javascript files', :green

        directory 'app/javascript/controllers'
        directory 'app/javascript/initializers'

        append_to_file 'app/javascript/application.js', <<~JS
          import './initializers/before_morph_handler.js'
        JS
      end

      def register_stimulus_controller
        say 'updating stimulus manifest', :green

        run 'rails stimulus:manifest:update'
      end
    end
  end
end

