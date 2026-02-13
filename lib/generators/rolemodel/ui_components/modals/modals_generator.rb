module Rolemodel
  module UiComponents
    class ModalsGenerator < BaseGenerator
      source_root File.expand_path('templates', __dir__)
      class_option :panels, type: :boolean, default: false, desc: 'Include RoleModel Panel Setup'

      def turbo_confirm
        say 'Installing Turbo Confirm package', :green

        run 'yarn add @rolemodel/turbo-confirm'
      end

      def helpers_and_views
        say 'generating views & helpers', :green

        copy_file 'app/helpers/turbo_frame_link_helper.rb'

        directory 'app/views/application'
        directory 'app/views/layouts'
      end

      def javascript_entrypoint
        say 'generating & importing javascript files', :green

        directory 'app/javascript/controllers'
        directory 'app/javascript/initializers'

        append_to_file 'app/javascript/application.js', <<~JS
          import './initializers/turbo_confirm.js'
          import './initializers/frame_missing_handler.js'
          import './initializers/before_morph_handler.js'
        JS
      end

      def inject_into_layout
        say 'updating application layout', :green

        inject_into_file 'app/views/layouts/application.html.slim', after: /\bbody.*\n/ do
          optimize_indentation <<~SLIM, 4
            = turbo_frame_tag 'modal'
            = render 'confirm'
          SLIM
        end
      end

      def to_panel_or_not_to_panel
        if options.panels?
          say 'Setting Up RoleModel Panel', :green

          inject_into_file 'app/views/layouts/application.html.slim', after: /\bturbo_frame_tag 'modal'\n/ do
            optimize_indentation <<~SLIM, 4
              = turbo_frame_tag 'panel'
            SLIM
          end

          inject_into_file 'app/assets/stylesheets/application.scss',
                          after: "@import '@rolemodel/optics/dist/css/optics';\n" do
            <<~SCSS
              @import '@rolemodel/optics/dist/css/addons/panel';
            SCSS
          end
        else
          remove_file 'app/views/layouts/panel.html.slim'
        end
      end

      def register_stimulus_controller
        say 'updating stimulus manifest', :green

        run 'rails stimulus:manifest:update'
      end
    end
  end
end
