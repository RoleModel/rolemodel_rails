module Rolemodel
  class ModalsGenerator < Rails::Generators::Base
    source_root File.expand_path('templates', __dir__)

    def install_turbo_confirm
      say 'Installing Turbo Confirm package', :green

      run 'yarn add @rolemodel/turbo-confirm'
    end

    def copy_files
      say 'generating views & link helpers', :green

      copy_file 'app/helpers/turbo_frame_link_helper.rb'
      template 'app/views/layouts/modal.html.slim'
      template 'app/views/layouts/panel.html.slim'
      copy_file 'app/views/application/_confirm.html.slim'
    end

    def amend_javascript_entrypoint
      say 'generating & importing javascript files', :green

      copy_file 'app/javascript/controllers/toggle_controller.js'
      copy_file 'app/javascript/initializers/turbo_confirm.js'
      copy_file 'app/javascript/initializers/frame_missing_handler.js'

      append_to_file 'app/javascript/application.js', <<~JS
        import './initializers/turbo_confirm'
        import './initializers/frame_missing_handler'
      JS
    end

    def amend_stylesheet_entrypoint
      say 'importing Optics stylesheets and defining custom properties', :green

      inject_into_file 'app/assets/stylesheets/application.scss',
                       after: "@import '@rolemodel/optics/dist/scss/optics';\n" do
        <<~SCSS
          @import '@rolemodel/optics/dist/scss/addons/panel';
        SCSS
      end
    end

    def amend_application_layout
      say 'amending application layout', :green

      inject_into_file 'app/views/layouts/application.html.slim', after: /\bbody.*\n/ do
        optimize_indentation <<~SLIM, 4
          = turbo_frame_tag 'modal'
          = turbo_frame_tag 'panel'
          = render 'confirm'
        SLIM
      end
    end

    def register_stimulus_controller
      say 'updating stimulus manifest', :green

      run 'rails stimulus:manifest:update'
    end
  end
end
