module Rolemodel
  module Turbo
    class AllGenerator < ::Rolemodel::GeneratorBase
      source_root File.expand_path('templates', __dir__)

      def run_generators
        generate 'rolemodel:turbo:confirm'
        generate 'rolemodel:turbo:modals'
      end
    end
  end
end

