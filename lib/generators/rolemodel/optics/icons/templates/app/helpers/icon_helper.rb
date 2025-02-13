# frozen_string_literal: true

# Helper methods to render icons from different icon libraries.
# Usage:
# You can use the `icon` helper method to render icons from the default library.
# = icon('home', size: 'x-large', color: 'primary')
# The default library is Material Icons, but can be changed here by changing the alias.
#
# You can also use the specific icon helper methods to render icons from a specific library.
# = material_icon('home', size: 'x-large', color: 'primary')
# = phosphor_icon('home', size: 'x-large', color: 'primary')
# = tabler_icon('home', size: 'x-large', color: 'primary')
# = feather_icon('home', size: 'x-large', color: 'primary')
# = lucide_icon('home', size: 'x-large', color: 'primary')
# = custom_icon('home', size: 'x-large', color: 'primary')
module IconHelper
  def icon_name_for_flash(type)
    # NOTE: This assumes material icon names
    case type
    when 'notice'
      'check_circle'
    when 'alert'
      'cancel'
    else
      type
    end
  end

  # filled, size, weight, emphasis, additional_classes, color, hover_text
  def material_icon(name, **)
    IconBuilder.from_library(:material, name, **).build
  end

  # duotone, filled, size, weight, additional_classes, color, hover_text
  def phosphor_icon(name, **)
    IconBuilder.from_library(:phosphor, name, **).build
  end

  # filled, size, additional_classes, color, hover_text
  def tabler_icon(name, **)
    IconBuilder.from_library(:tabler, name, **).build
  end

  # size, additional_classes, color, hover_text
  def feather_icon(name, **)
    IconBuilder.from_library(:feather, name, **).build
  end

  # size, additional_classes, color, hover_text
  def lucide_icon(name, **)
    IconBuilder.from_library(:lucide, name, **).build
  end

  # filled, size, weight, emphasis, additional_classes, color, hover_text
  def custom_icon(name, **)
    IconBuilder.from_library(:custom, name, **).build
  end

  # Set the default to Material Icons
  alias icon material_icon
  # Might be more interesting to look into https://www.rubydoc.info/gems/thor/Thor/Shell/Basic#ask-instance_method
  # We could prompt which icon library they'd like the generator to "install" and inject this line dynamically based on
  # what's selected. Maybe also comment out or not bring in the icon packs that are not being used.
end
