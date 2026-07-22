module Rolemodel
  module Turbo
    class AllGenerator < ::Rolemodel::GeneratorBase
      source_root File.expand_path('templates', __dir__)

      def run_generators
        generate 'rolemodel:turbo:ready'
        generate 'rolemodel:turbo:confirm'
        generate 'rolemodel:turbo:modals'
        generate 'rolemodel:turbo:form'
      end
    end
  end
end

