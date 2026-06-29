# frozen_string_literal: true

module Rolemodel
  module Optics
    # Generates the icon helper and icon builders for the chosen icon library
    class IconsGenerator < Rolemodel::GeneratorBase
      BUILDER_DIR = 'rolemodel/optics'
      SUPPORTED_LIBRARIES = HashWithIndifferentAccess.new(
        material: 'filled, size, weight, emphasis, additional_classes, color, hover_text',
        phosphor: 'duotone, filled, size, weight, additional_classes, color, hover_text',
        tabler: 'filled, size, additional_classes, color, hover_text',
        feather: 'size, additional_classes, color, hover_text',
        lucide: 'size, additional_classes, color, hover_text',
        custom: 'filled, size, weight, emphasis, additional_classes, color, hover_text'
      ).freeze

      source_root File.expand_path('templates', __dir__)
      class_option :install_builders, aliases: '-i', type: :boolean, default: false,
                   desc: "Install IconBuilder classes for customization"

      class_exclusive do
        SUPPORTED_LIBRARIES.keys.each do |library|
          class_option library, type: :boolean, lazy_default: false, desc: "Use #{library} icon library"
        end
      end

      def add_view_helper
        @chosen_library = capture_user_selection
        @supported_properties = SUPPORTED_LIBRARIES.fetch(@chosen_library)

        template 'app/helpers/icon_helper.rb', force: true
      end

      def install_builders
        return unless options.install_builders?

        source_paths << File.expand_path(BUILDER_DIR, Rolemodel::GEM_LIB)
        copy_file 'icon_builder.rb', "lib/#{BUILDER_DIR}/icon_builder.rb", force: true
        copy_file "#{@chosen_library}_icon_builder.rb", "lib/#{BUILDER_DIR}/#{@chosen_library}_icon_builder.rb", force: true
      end

    private

      def capture_user_selection
        options.slice(*SUPPORTED_LIBRARIES.keys).invert[true] || ask(
          'What icon library would you like to add?',
          default: SUPPORTED_LIBRARIES.keys.first.to_s,
          limited_to: SUPPORTED_LIBRARIES.keys.map(&:to_s)
        )
      end
    end
  end
end
