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

      def inject_meta_tags
        say 'adding meta tags to head partial', :green

        inject_into_file 'app/views/application/_head.html.slim', after: /meta name="viewport".*\n/ do
          optimize_indentation <<~SLIM
            meta name="turbo-refresh-method" content="morph"
            meta name="turbo-refresh-scroll" content="preserve"
          SLIM
        end
      end

      def inject_head_outlet
        say 'adding head outlet to head partial', :green

        inject_into_file 'app/views/application/_head.html.slim', after: /javascript_include_tag.*\n/ do
          optimize_indentation <<~SLIM

            = yield :head
          SLIM
        end
      end

      def register_stimulus_controller
        say 'updating stimulus manifest', :green

        rails_command 'stimulus:manifest:update'
      end
    end
  end
end

