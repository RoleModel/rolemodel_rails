# frozen_string_literal: true

require_relative 'icons_generator'

module Rolemodel
  module Optics
    # For generators that run optics:icons: accept its icon library flag (e.g. --material) and pass
    # it along, so the icons generator doesn't stop to ask.
    module IconLibraryOptions
      LIBRARIES = IconsGenerator::SUPPORTED_LIBRARIES.keys.freeze

      def self.included(base)
        base.class_exclusive do
          LIBRARIES.each { base.class_option it, type: :boolean, lazy_default: false, desc: "Use #{it} icon library" }
        end
      end

      private

      def icon_library_flags = LIBRARIES.select { options[it] }.map { "--#{it}" }
    end
  end
end
