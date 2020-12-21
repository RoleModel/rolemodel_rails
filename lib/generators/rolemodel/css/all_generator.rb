module Rolemodel
  module Css
    class AllGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      def run_all_the_generators
        generate 'rolemodel:css:base'
        generate 'rolemodel:css:icons'
      end
    end
  end
end
