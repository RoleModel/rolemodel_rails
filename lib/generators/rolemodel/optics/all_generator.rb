module Rolemodel
  module Optics
    class AllGenerator < BaseGenerator
      source_root File.expand_path('templates', __dir__)

      def run_all_the_generators
        generate 'rolemodel:optics:base'
        generate 'rolemodel:optics:icons'
      end
    end
  end
end
