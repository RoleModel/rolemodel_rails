module Rolemodel
  class ModalsGenerator < Rails::Generators::Base
    source_root File.expand_path('templates', __dir__)

    def install_icons
      generate 'rolemodel:css:base' unless File.exists?(Rails.root.join('app/javascript/packs/stylesheets.scss'))
      generate 'rolemodel:css:icons'
    end

    def install_turbolinks_animate
      run 'yarn add turbolinks-animate'
    end

    def add_stuff
      copy_file 'app/helpers/modal_helper.rb'
      addendum = File.read([source_paths.first, '/application_addendum.js'].join)
      append_to_file 'app/javascript/packs/application.js', addendum
      copy_file 'app/layouts/application.html.slim'
      copy_file 'app/views/shared/_custom_confirm.html.slim'
      copy_file 'app/views/shared/_modal.html.slim'
      # copy_file 'doc/modal.md'
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

        VARIABLES
      end
    end
  end
end
