require 'rolemodel/yarn'

module Rolemodel
  module Turbo
    class ModalsGenerator < ::Rolemodel::GeneratorBase
      source_root File.expand_path('templates', __dir__)
      class_option :panels, type: :boolean, default: false, desc: 'Include RoleModel Panel Setup'

      def helpers_and_views
        say 'generating views & helpers', :green

        directory 'app/helpers'
        directory 'app/views/layouts'
      end

      def javascript_entrypoint
        say 'generating & importing javascript files', :green

        directory 'app/javascript/controllers'
        directory 'app/javascript/initializers'

        append_to_file 'app/javascript/application.js', <<~JS
          import './initializers/frame_missing_handler.js'
        JS
      end

      def inject_into_layout
        say 'updating application layout', :green

        inject_into_file 'app/views/layouts/application.html.slim', after: /\bbody.*\n/ do
          optimize_indentation <<~SLIM, 4
            = turbo_frame_tag 'modal'
          SLIM
        end
      end

      def to_panel_or_not_to_panel
        if options.panels?
          say 'Setting Up RoleModel Panel', :green

          inject_into_file 'app/views/layouts/application.html.slim', after: /\bturbo_frame_tag 'modal'.*\n/ do
            optimize_indentation <<~SLIM, 4
              = turbo_frame_tag 'panel'
            SLIM
          end

          append_to_file application_stylesheet_path, <<~CSS
            @import '@rolemodel/optics/dist/css/addons/panel';
          CSS
        else
          remove_file 'app/views/layouts/panel.html.slim'
        end
      end

      def register_stimulus_controller
        say 'updating stimulus manifest', :green

        rails_command 'stimulus:manifest:update'
      end
    end
  end
end

