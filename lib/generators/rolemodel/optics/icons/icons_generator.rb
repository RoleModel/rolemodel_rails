# frozen_string_literal: true

module Rolemodel
  module Optics
    # Generates the icon helper and icon builders for the chosen icon library
    class IconsGenerator < Rolemodel::BaseGenerator
      SUPPORTED_LIBRARIES = HashWithIndifferentAccess.new(
        material: 'filled, size, weight, emphasis, additional_classes, color, hover_text',
        phosphor: 'duotone, filled, size, weight, additional_classes, color, hover_text',
        tabler: 'filled, size, additional_classes, color, hover_text',
        feather: 'size, additional_classes, color, hover_text',
        lucide: 'size, additional_classes, color, hover_text',
        custom: 'filled, size, weight, emphasis, additional_classes, color, hover_text'
      ).freeze

      source_root File.expand_path('templates', __dir__)
      class_exclusive do
        SUPPORTED_LIBRARIES.keys.each do |library|
          class_option library, type: :boolean, lazy_default: false, desc: "Use #{library} icon library"
        end
      end

      def remove_existing_icon_helper_and_builders
        remove_dir 'app/icon_builders'
        remove_file 'app/helpers/icon_helper.rb'
      end

      def add_view_helper
        @chosen_library = capture_user_selection
        @supported_properties = SUPPORTED_LIBRARIES.fetch(@chosen_library)

        template 'app/icon_builders/icon_builder.rb'
        template "app/icon_builders/#{@chosen_library}_icon_builder.rb"
        template 'app/helpers/icon_helper.rb'
      end

    private

      def capture_user_selection
        options.except(*%i[skip_namespace skip_collision_check]).invert[true] || ask(
          'What icon library would you like to add?',
          default: SUPPORTED_LIBRARIES.keys.first.to_s,
          limited_to: SUPPORTED_LIBRARIES.keys.map(&:to_s)
        )
      end
    end
  end
end
