# frozen_string_literal: true

# TablerIconBuilder is an IconBuilder that allows for Tabler icons to be used in the application.
# https://tablericons.com/
class TablerIconBuilder < IconBuilder
  private

  def tag_method
    :i
  end

  def tag_classes
    ['ti', filled ? "ti-#{name}-filled" : "ti-#{name}"].concat(super)
  end
end
