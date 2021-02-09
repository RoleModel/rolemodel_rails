module Rolemodel
  class ModalsGenerator < Rails::Generators::Base
    source_root File.expand_path('templates', __dir__)

    def install_icons
      generate 'rolemodel:css:base' unless File.exists?(Rails.root.join('app/javascript/packs/stylesheets.scss'))
      generate 'rolemodel:css:icons'
    end

    def add_ui_components
      copy_file 'app/helpers/modal_helper.rb'
      addendum = File.read([source_paths.last, '/application_addendum.js'].join)
      append_to_file 'app/javascript/packs/application.js', addendum
      copy_file 'app/javascript/packs/rolemodel-custom-confirm.js'
      copy_file 'app/javascript/packs/rolemodel-modal.js'
      copy_file 'app/javascript/packs/rolemodel-panel.js'
      copy_file 'app/javascript/packs/makeFormsRemote.js'
      copy_file 'app/views/layouts/application.html.slim'
      copy_file 'app/views/shared/_custom_confirm.html.slim'
      copy_file 'app/views/shared/_modal.html.slim'
    end

    def add_css
      copy_file 'app/javascript/stylesheets/components/panel.scss'
      copy_file 'app/javascript/stylesheets/components/modal.scss'
      inject_into_file 'app/javascript/packs/stylesheets.scss', "@import 'stylesheets/components/panel';\n", before: "@import 'stylesheets/styleguide'"
      inject_into_file 'app/javascript/packs/stylesheets.scss', "@import 'stylesheets/components/modal';\n\n", before: "@import 'stylesheets/styleguide'"

      inject_into_file 'app/javascript/stylesheets/variables.scss', before: "  // Spacing" do
        optimize_indentation <<~'VARIABLES', 2
          // Panel
          --panel-width: 40%;
          --panel-transition-speed: 400ms;

          // Modals
          --modal-transition-speed: 300ms;

        VARIABLES
      end
    end

    def add_documentation
      copy_file 'doc/modal.md'
    end
  end
end
