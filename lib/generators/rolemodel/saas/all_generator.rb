module Rolemodel
  module Saas
    class AllGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      def run_all_the_generators
        generate 'rolemodel:saas:devise'
        generate 'rolemodel:saas:stripe'
      end
    end
  end
end
