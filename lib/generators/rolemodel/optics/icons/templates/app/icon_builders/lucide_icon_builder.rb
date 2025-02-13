# frozen_string_literal: true

# LucideIconBuilder is an IconBuilder that allows for Lucide icons to be used in the application.
# https://lucide.dev/icons/
class LucideIconBuilder < IconBuilder
  def self.flash_icons
    {
      notice: 'circle-check',
      alert: 'circle-x'
    }
  end

  private

  def tag_method
    :i
  end

  def tag_classes
    ['li', "li-#{name}"].concat(super)
  end
end
