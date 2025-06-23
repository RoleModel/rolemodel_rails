module Rolemodel
  class ModalsGenerator < Rails::Generators::Base
    source_root File.expand_path('templates', __dir__)

    def configuration
      say 'Configuring Generator, please answer 2 questions', :green
      @panel_install = yes? 'Would you like to install RoleModel Panel as well? (Y/n)', :magenta
      @node_install = yes? 'Will there be a build step for JavaScript compilation by Node? (Y/n)', :magenta
    end

    def install_turbo_confirm
      say 'Installing Turbo Confirm package', :green

      if @node_install
        run 'yarn add @rolemodel/turbo-confirm'
      else
        run 'bin/importmap pin @rolemodel/turbo-confirm'
      end
    end

    def copy_files
      say 'generating views & link helpers', :green

      template 'app/helpers/turbo_frame_link_helper.rb'
      template 'app/views/layouts/modal.html.slim'
      template('app/views/layouts/panel.html.slim') if @panel_install
      template 'app/views/application/_confirm.html.slim'
    end

    def amend_javascript_entrypoint
      say 'generating & importing javascript files', :green

      template 'app/javascript/controllers/toggle_controller.js'
      template 'app/javascript/initializers/turbo_confirm.js'
      template 'app/javascript/initializers/frame_missing_handler.js'
      template 'app/javascript/initializers/before_morph_handler.js'

      append_to_file 'app/javascript/application.js', <<~JS
        import './initializers/turbo_confirm.js'
        import './initializers/frame_missing_handler.js'
        import './initializers/before_morph_handler.js'
      JS
    end

    def amend_stylesheet_entrypoint
      return unless @panel_install

      say 'importing Optics Panel add-on', :green

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
        if @panel_install
          optimize_indentation <<~SLIM, 4
            = turbo_frame_tag 'modal'
            = turbo_frame_tag 'panel'
            = render 'confirm'
          SLIM
        else
          optimize_indentation <<~SLIM, 4
            = turbo_frame_tag 'modal'
            = render 'confirm'
          SLIM
        end
      end
    end

    def register_stimulus_controller
      say 'updating stimulus manifest', :green

      run 'rails stimulus:manifest:update'
    end
  end
end
