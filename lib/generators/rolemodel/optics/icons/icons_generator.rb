module Rolemodel
  module Optics
    class IconsGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      def add_view_helper
        say 'generating icon helper', :green

        copy_file 'app/helpers/icon_helper.rb'
        directory 'app/icon_builders'
      end
    end
  end
end
