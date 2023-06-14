

module Rolemodel
  class ModalsGenerator < Rails::Generators::Base
    source_root File.expand_path('templates', __dir__)

    STYLESHEET_ENTRYPOINT = 'app/assets/stylesheets/application.scss'
    JAVASCRIPT_ENTRYPOINT = 'app/javascript/application.js'

    def install_turbo_confirm
      say 'Installing Turbo Confirm package', :green
      run 'yarn add @rolemodel/turbo-confirm'
    end

    def copy_files
      say 'generating files', :green
      copy_file 'app/helpers/turbo_frame_link_helper.rb'
      copy_file 'app/javascript/controllers/toggle_controller.js'
      copy_file 'app/javascript/initializers/turbo_confirm.js'
      copy_file 'app/javascript/initializers/frame_missing_handler.js'
      copy_file 'app/views/layouts/modal.html.slim'
      copy_file 'app/views/layouts/panel.html.slim'
      copy_file 'app/views/shared/_confirm.html.slim'
    end

    def amend_javascript_entrypoint
      say 'importing generated javascript files', :green
      append_to_file 'app/javascript/application.js', <<~JS
        import './initializers/turbo_confirm'
        import './initializers/frame_missing_handler'
      JS
    end

    def amend_stylesheet_entrypoint
      say 'importing stylesheet addons', :green
      inject_into_file 'app/assets/stylesheets/application.scss', after: "@import '@rolemodel/optics/dist/scss/optics';\n" do
        optimize_indentation <<~SCSS, 2
          @import '@rolemodel/optics/dist/scss/addons/rails-modal-and-panel/modal';
          @import '@rolemodel/optics/dist/scss/addons/rails-modal-and-panel/panel';

          // Panel tokens
          --panel-width: 40%;
          --panel-transition-speed: 400ms;

          // Modals tokens
          --modal-width: 564px;
          --modal-transition-speed: 300ms;
        SCSS
      end
    end

    def amend_application_layout
      say 'altering application layout', :green
      inject_into_file 'app/views/layouts/application.html.slim', after: /\bbody.*\n/ do
        optimize_indentation <<~SLIM, 2
          = turbo_frame_tag 'modal'
          = turbo_frame_tag 'panel'
          = render 'shared/confirm'
        SLIM
      end
    end

    def register_stimulus_controller
      say 'updating stimulus manifest', :green
      run 'rails stimulus:manifest:update'
    end
  end
end
