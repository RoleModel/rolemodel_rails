# frozen_string_literal: true

class IconBuilder
  include ActionView::Helpers::TagHelper

  attr_reader :name, :filled, :size, :weight, :emphasis, :duotone, :additional_classes, :color, :hover_text

  DEFAULT_SIZE = 'medium'
  DEFAULT_WEIGHT = 'normal'
  DEFAULT_EMPHASIS = 'normal'

  def initialize( # rubocop:disable Metrics/ParameterLists
    name,
    filled: false,
    size: DEFAULT_SIZE,
    weight: DEFAULT_WEIGHT,
    emphasis: DEFAULT_EMPHASIS,
    duotone: false,
    additional_classes: '',
    color: '',
    hover_text: name
  )
    @name = name
    @filled = filled
    @size = size
    @weight = weight
    @emphasis = emphasis
    @duotone = duotone
    @additional_classes = additional_classes
    @color = color
    @hover_text = hover_text
  end

  def self.flash_icon(type, **)
    new(flash_icons[type.to_sym], **)
  end

  def self.flash_icons
    raise NotImplementedError
  end

  def build
    options = {
      class: tag_classes.compact_blank.join(' '),
      title: hover_text
    }

    if color.present?
      # color: primary, neutral, alerts-notice, alerts-warning, alerts-danger, alerts-info
      options[:style] = "#{color_attribute}: var(--op-color-#{color}-base);"
    end

    tag.send(tag_method, tag_contents, **options)
  end

  private

  def tag_method
    raise NotImplementedError
  end

  def tag_contents
    ''
  end

  def tag_classes
    ['icon', size == DEFAULT_SIZE ? '' : "icon--#{size}", additional_classes]
  end

  def color_attribute
    'color'
  end
end
