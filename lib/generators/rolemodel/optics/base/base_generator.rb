require 'rolemodel/yarn'

module Rolemodel
  module Optics
    class BaseGenerator < Rolemodel::GeneratorBase
      source_root File.expand_path('templates', __dir__)

      def add_optics_package
        say 'installing Optics package', :green

        invoke 'rolemodel:yarn:setup'
        run 'yarn add @rolemodel/optics'
      end

      def copy_templates
        say 'importing stylesheet', :green

        prepend_to_file application_stylesheet_path, <<~CSS
          @import '@rolemodel/optics/dist/css/optics';
        CSS
      end
    end
  end
end
