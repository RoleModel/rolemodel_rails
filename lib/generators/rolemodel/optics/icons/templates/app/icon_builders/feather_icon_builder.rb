# frozen_string_literal: true

# FeatherIconBuilder is an IconBuilder that allows for Feather icons to be used in the application.
# https://feathericons.com/
class FeatherIconBuilder < IconBuilder
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
    ['fi', "fi-#{name}"].concat(super)
  end
end
