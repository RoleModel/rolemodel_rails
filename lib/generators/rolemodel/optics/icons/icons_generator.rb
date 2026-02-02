# frozen_string_literal: true

module Rolemodel
  module Optics
    # Generates the icon helper and icon builders for the chosen icon library
    class IconsGenerator < Rolemodel::BaseGenerator
      source_root File.expand_path('templates', __dir__)

      SUPPORTED_LIBRARIES = HashWithIndifferentAccess.new(
        material: 'filled, size, weight, emphasis, additional_classes, color, hover_text',
        phosphor: 'duotone, filled, size, weight, additional_classes, color, hover_text',
        tabler: 'filled, size, additional_classes, color, hover_text',
        feather: 'size, additional_classes, color, hover_text',
        lucide: 'size, additional_classes, color, hover_text',
        custom: 'filled, size, weight, emphasis, additional_classes, color, hover_text'
      ).freeze

      source_root File.expand_path('templates', __dir__)
      class_option :icon_library, type: :string, default: SUPPORTED_LIBRARIES.keys.first,
                                  desc: "The icon library to use (#{SUPPORTED_LIBRARIES.keys.join(', ')})"

      def remove_existing_icon_helper_and_builders
        remove_dir 'app/icon_builders'
        remove_file 'app/helpers/icon_helper.rb'
      end

      def add_view_helper
        say 'Generating IconHelper Module', :green

        @chosen_library = options['icon_library']
        @supported_properties = SUPPORTED_LIBRARIES.fetch(@chosen_library)

        template 'app/icon_builders/icon_builder.rb'
        template "app/icon_builders/#{@chosen_library}_icon_builder.rb"
        template 'app/helpers/icon_helper.rb'
      end
    end
  end
end
