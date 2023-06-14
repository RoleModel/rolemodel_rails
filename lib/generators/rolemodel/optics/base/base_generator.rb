module Rolemodel
  module Optics
    class BaseGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      def add_optics_package
        run 'yarn add @rolemodel/optics'
      end

      def copy_templates
        copy_file 'app/assets/stylesheets/application.scss'
      end
    end
  end
end
