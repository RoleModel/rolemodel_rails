# frozen_string_literal: true

# TablerIconBuilder is an IconBuilder that allows for Tabler icons to be used in the application.
# https://tablericons.com/
class TablerIconBuilder < IconBuilder
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
    ['ti', filled ? "ti-#{name}-filled" : "ti-#{name}"].concat(super)
  end
end
