# frozen_string_literal: true

module Rolemodel
  module Optics
    # Generates the icon helper and icon builders for the chosen icon library
    class IconsGenerator < BaseGenerator
      source_root File.expand_path('templates', __dir__)

      SUPPORTED_LIBRARIES = {
        material: 'filled, size, weight, emphasis, additional_classes, color, hover_text',
        phosphor: 'duotone, filled, size, weight, additional_classes, color, hover_text',
        tabler: 'filled, size, additional_classes, color, hover_text',
        feather: 'size, additional_classes, color, hover_text',
        lucide: 'size, additional_classes, color, hover_text',
        custom: 'filled, size, weight, emphasis, additional_classes, color, hover_text'
      }.freeze

      def add_view_helper
        say 'generating icon helper', :green

        @chosen_library = ask(
          'What icon library would you like to add?',
          default: SUPPORTED_LIBRARIES.keys.first.to_s,
          limited_to: SUPPORTED_LIBRARIES.keys.map(&:to_s)
        )

        @supported_properties = SUPPORTED_LIBRARIES[@chosen_library.to_sym]

        copy_file 'app/icon_builders/icon_builder.rb'
        copy_file "app/icon_builders/#{@chosen_library}_icon_builder.rb"
        template 'app/helpers/icon_helper.rb'
      end
    end
  end
end
