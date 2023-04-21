module Rolemodel
  module Optics
    class IconsGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      def add_view_helper
        copy_file 'app/helpers/icon_helper.rb'
      end
    end
  end
end
