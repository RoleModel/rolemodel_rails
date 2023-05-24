# frozen_string_literal: true

# rubocop:disable Metrics/ParameterLists

module IconHelper
  def icon_name_for_flash(type)
    case type
    when 'notice'
      'check_circle'
    when 'alert'
      'cancel'
    else
        type
    end
  end

  def material_icon(name, filled: false, size: 'medium', weight: 'normal', emphasis: 'normal', color: nil, classes: nil, hover_text: name)
    options = {
      class: classes(false, filled, size, weight, emphasis, classes),
      title: hover_text
    }

    options[:style] = "color: var(--op-color-#{color}-base);" if color # primary, neutral, alerts-danger, alerts-warning, alerts-notice, alerts-notice

    tag.span(name, **options)
  end

  def icon(name, filled: false, size: 'medium', weight: 'normal', emphasis: 'normal', color: nil, classes: nil, hover_text: name)
    using_custom_icon = custom_icon_path(name).present?

    contents = using_custom_icon ? embedded_svg("icons/#{name}.svg") : name

    options = {
      class: classes(using_custom_icon, filled, size, weight, emphasis, classes),
      title: hover_text
    }

    if color
      options[:style] = "#{using_custom_icon ? 'fill' : 'color'}: var(--rms-colors-#{color}-base);"
    end

    tag.span(contents, **options)
  end

  # Inspired by https://blog.cloud66.com/using-svgs-in-a-rails-stack
  def embedded_svg(filename, options = {})
    asset = Rails.application.assets_manifest.find_sources(filename).first

    if asset
      file = asset.source.force_encoding('UTF-8')
      doc = Nokogiri::HTML::DocumentFragment.parse file
      svg = doc.at_css 'svg'
      svg['class'] = options[:class] if options[:class].present?
    else
      doc = "<!-- SVG #{filename} not found -->"
    end

    # These SVG files can safely be marked html_safe since we created them and they are part of this app's code.
    raw doc # rubocop:disable Rails/OutputSafety
  end

  private

  def classes(using_custom_icon, filled, size, weight, emphasis, additional_classes = nil)
    shape_class = filled ? 'icon--filled' : 'icon--outlined' # true, false
    size_class = "icon--#{size}" # normal, large, x-large
    weight_class = "icon--weight-#{weight}" # light, normal, semi-bold, bold
    emphasis_class = "icon--#{emphasis}-emphasis" # low, normal, high

    base_class = using_custom_icon ? 'custom-icons' : 'material-symbols-outlined'
    "#{base_class} #{shape_class} #{size_class} #{weight_class} #{emphasis_class} #{additional_classes}"
  end
  # rubocop:enable Metrics/ParameterLists

  def custom_icon_path(name)
    Rails.application.assets_manifest.find_sources("icons/#{name}.svg").first
  end
end
