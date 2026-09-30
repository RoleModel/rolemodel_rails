# frozen_string_literal: true

# CustomIconBuilder is an IconBuilder that allows for custom SVG icons to be used in the application.
# It inlines app/assets/images/icons/<name>.svg, so any SVG set works, including Hugeicons:
#
#   icon('home-01')                   # icons/home-01.svg
#   icon('duotone-rounded/home-01')   # icons/duotone-rounded/home-01.svg
class Rolemodel::Optics::CustomIconBuilder < Rolemodel::Optics::IconBuilder
  def self.flash_icons
    {
      notice: 'circle-check',
      alert: 'circle-x'
    }
  end

  private

  def tag_method
    :span
  end

  def tag_contents
    # Inspired by https://blog.cloud66.com/using-svgs-in-a-rails-stack
    source = svg_source
    return "<!-- SVG #{svg_path} not found -->".html_safe if source.nil?

    # These SVG files can safely be marked html_safe since we created them and they are part of this app's code.
    source.dup.force_encoding('UTF-8').html_safe
  end

  # Propshaft and Sprockets find assets differently.
  def svg_source
    assets = Rails.application.assets
    if assets.respond_to?(:load_path)
      assets.load_path.find(svg_path)&.content
    else
      Rails.application.assets_manifest.find_sources(svg_path).first&.source
    end
  end

  def tag_classes
    [
      'svg-icon',
      filled ? 'icon--filled' : '',
      weight == DEFAULT_WEIGHT ? '' : "icon--weight-#{weight}",
      emphasis == DEFAULT_EMPHASIS ? '' : "icon--#{emphasis}-emphasis"
    ].concat(super)
  end

  def color_attribute
    'fill'
  end

  def svg_path
    "icons/#{name}.svg"
  end
end
