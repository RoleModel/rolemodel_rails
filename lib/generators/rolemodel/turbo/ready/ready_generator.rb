module Rolemodel
  module Turbo
    class ReadyGenerator < ::Rolemodel::GeneratorBase
      source_root File.expand_path('templates', __dir__)

      def add_javascript_initializer
        say 'generating & importing morph event handlers', :green

        directory 'app/javascript/initializers'

        append_to_file 'app/javascript/application.js', <<~JS
          import './initializers/before_morph_handler.js'
        JS
      end

      def add_stimulus_controller
        say 'adding prevent-morph controller & updating manifest', :green

        directory 'app/javascript/controllers'

        rails_command 'stimulus:manifest:update'
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

        append_to_file 'app/views/application/_head.html.slim' do
          optimize_indentation <<~SLIM

            = yield :head
          SLIM
        end
      end
    end
  end
end

