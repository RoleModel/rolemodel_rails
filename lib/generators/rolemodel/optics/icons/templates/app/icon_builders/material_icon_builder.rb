# frozen_string_literal: true

# MaterialIconBuilder is an IconBuilder that allows for Material icons to be used in the application.
# https://fonts.google.com/icons
class MaterialIconBuilder < IconBuilder
  def self.flash_icons
    {
      notice: 'check_circle',
      alert: 'cancel'
    }
  end

  private

  def tag_method
    :span
  end

  def tag_contents
    name
  end

  def tag_classes
    [
      'material-symbols-outlined',
      filled ? 'icon--filled' : '',
      weight == DEFAULT_WEIGHT ? '' : "icon--weight-#{weight}",
      emphasis == DEFAULT_EMPHASIS ? '' : "icon--#{emphasis}-emphasis"
    ].concat(super)
  end
end
