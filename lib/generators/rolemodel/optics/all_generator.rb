require_relative 'icons/icon_library_options'

module Rolemodel
  module Optics
    class AllGenerator < Rolemodel::GeneratorBase
      include IconLibraryOptions

      source_root File.expand_path('templates', __dir__)

      def run_all_the_generators
        generate 'rolemodel:optics:base'
        generate 'rolemodel:optics:icons', *icon_library_flags
      end
    end
  end
end
