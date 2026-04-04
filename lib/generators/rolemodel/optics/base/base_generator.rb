module Rolemodel
  module Optics
    class BaseGenerator < Rolemodel::GeneratorBase
      source_root File.expand_path('templates', __dir__)

      def add_optics_package
        say 'installing Optics package', :green

        run 'yarn add @rolemodel/optics'
      end

      def copy_templates
        say 'importing stylesheet', :green

        prepend_to_file Dir.glob('app/assets/stylesheets/application.*').first, <<~SCSS
          @import '@rolemodel/optics/dist/css/optics';
        SCSS
      end
    end
  end
end
