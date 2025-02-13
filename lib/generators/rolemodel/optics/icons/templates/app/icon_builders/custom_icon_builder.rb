# frozen_string_literal: true

# CustomIconBuilder is an IconBuilder that allows for custom SVG icons to be used in the application.
class CustomIconBuilder < IconBuilder
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

  # NOTE: This does not work with propshaft and the latest asset pipeline
  # We will need to find a way to make this work in Rails 8 with propshaft.
  def tag_contents # rubocop:disable Metrics/AbcSize
    # Inspired by https://blog.cloud66.com/using-svgs-in-a-rails-stack
    asset = Rails.application.assets_manifest.find_sources(svg_path).first

    if asset
      file = asset.source.force_encoding('UTF-8')
      doc = Nokogiri::HTML::DocumentFragment.parse file
      svg = doc.at_css 'svg'
      svg['class'] = options[:class] if options[:class].present?
    else
      doc = "<!-- SVG #{svg_path} not found -->"
    end

    # These SVG files can safely be marked html_safe since we created them and they are part of this app's code.
    raw doc
  end

  def tag_classes
    [
      'custom-icons',
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
