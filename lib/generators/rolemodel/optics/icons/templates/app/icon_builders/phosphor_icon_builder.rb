# frozen_string_literal: true

# PhosphorIconBuilder is an IconBuilder that allows for Phosphor icons to be used in the application.
# https://phosphoricons.com/
class PhosphorIconBuilder < IconBuilder
  def self.flash_icons
    {
      notice: 'check-circle',
      alert: 'x-circle'
    }
  end

  private

  def tag_method
    :i
  end

  def tag_classes
    [
      duotone ? 'ph-duotone' : 'ph',
      "ph-#{name}",
      filled ? 'icon--filled' : '',
      weight == DEFAULT_WEIGHT ? '' : "icon--weight-#{weight}"
    ].concat(super)
  end
end
