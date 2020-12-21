module Rolemodel
  module Css
    class IconsGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      def add_material_icons
        run 'yarn add material-icons'
      end

      def add_view_helper
        copy_file 'app/helpers/icon_helper.rb'
      end

      def add_css
        copy_file 'app/javascript/stylesheets/components/icon.scss'
        append_file 'app/javascript/packs/stylesheets.scss', "@import 'stylesheets/components/icon';"
      end
    end
  end
end
