module Rolemodel
  class ModalsGenerator < Rails::Generators::Base
    source_root File.expand_path('templates', __dir__)

    STYLESHEET_ROOT = 'app/javascript/stylesheets'.freeze
    STYLESHEET_ENTRYPOINT = 'app/javascript/packs/stylesheets.scss'.freeze
    OPTICS_MODAL_STYLE_PATH = 'https://raw.githubusercontent.com/RoleModel/optics/main/src/addons/rails-modal-and-panel/modal.scss'.freeze
    OPTICS_PANEL_STYLE_PATH = 'https://raw.githubusercontent.com/RoleModel/optics/main/src/addons/rails-modal-and-panel/panel.scss'.freeze

    def install_turbo_confirm
      run 'yarn add @rolemodel/turbo-confirm'
    end

    def install_icons
      generate 'rolemodel:css:base' unless File.exists?(Rails.root.join('app/javascript/packs/stylesheets.scss'))
      generate 'rolemodel:css:icons'
    end

    def add_ui_components
      copy_file 'app/helpers/turbo_frame_link_helper.rb'
      addendum = File.read([source_paths.last, '/application_addendum.js'].join)
      append_to_file 'app/javascript/packs/application.js', addendum
      copy_file 'app/javascript/controllers/toggle_controller.js'
      copy_file 'app/views/layouts/application.html.slim'
      copy_file 'app/views/layouts/modal.html.slim'
      copy_file 'app/views/layouts/panel.html.slim'
      copy_file 'app/views/shared/_confirm.html.slim'
    end

    def add_css
      if yes?('Are you using Optics?')
        import_optics_addons
      else
        inject_optics_stylesheets
      end

      inject_into_file "#{STYLESHEET_ROOT}/variables/tokens.scss", before: "  // Spacing" do
        optimize_indentation <<~'SCSS', 2
          // Panel
          --panel-width: 40%;
          --panel-transition-speed: 400ms;

          // Modals
          --modal-width: 564px;
          --modal-transition-speed: 300ms;

        SCSS
      end
    end

    def add_to_styleguide
      inject_into_file 'app/controllers/styleguide_controller.rb', after: "def index; end\n" do
        optimize_indentation <<~'RUBY', 2

          def popup
            render layout: params[:type]
          end
        RUBY
      end

      route "get '/styleguide/popup/:type', to: 'styleguide#popup', as: :styleguide_popup"
      copy_file 'app/views/styleguide/popup_content.html.slim'
      copy_file 'app/views/styleguide/_modals.html.slim'
      append_to_file 'app/views/styleguide/index.html.slim', "  = render 'modals'"
    end

    private

    def import_optics_addons
      inject_into_file STYLESHEET_ENTRYPOINT, after: "@import '@rolemodel/optics/dist/scss/optics';" do
        optimize_indentation <<~'SCSS', 2
          @import '@rolemodel/optics/dist/scss/addons/rails-modal-and-panel/modal';
          @import '@rolemodel/optics/dist/scss/addons/rails-modal-and-panel/panel';
        SCSS
      end
    end

    def inject_optics_stylesheets
      get OPTICS_MODAL_STYLE_PATH do |modal_styles|
        create_file "#{STYLESHEET_ROOT}/components/modal.scss" do
          modal_styles
        end
      end

      get OPTICS_PANEL_STYLE_PATH do |panel_styles|
        create_file "#{STYLESHEET_ROOT}/components/panel.scss" do
          panel_styles
        end
      end

      append_to_file STYLESHEET_ENTRYPOINT, <<~SCSS
        @import 'stylesheets/components/modal.scss';
        @import 'stylesheets/components/panel.scss';
      SCSS
    end
  end
end
