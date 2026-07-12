module Rolemodel
  module Optics
    class AllGenerator < Rolemodel::GeneratorBase
      source_root File.expand_path('templates', __dir__)

      # Composite generator: orchestrates other generators, not recorded itself.
      skip_registry_entry!

      def run_all_the_generators
        generate 'rolemodel:optics:base'
        generate 'rolemodel:optics:icons'
      end
    end
  end
end
