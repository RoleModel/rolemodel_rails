# frozen_string_literal: true

# HugeiconsIconBuilder is an SvgIconBuilder for Hugeicons (https://hugeicons.com/).
# The app keeps the SVGs it uses in app/icons/hugeicons/<style>/<name>.svg.
# `bin/rails optics:icons:vendor` fetches them; see Rolemodel::Optics::Hugeicons.
#
#   icon('home-01')                          # stroke-rounded
#   icon('home-01', filled: true)            # solid-rounded
#   icon('home-01', duotone: true)           # duotone-rounded
#   icon('home-01', style: 'twotone-rounded')
class Rolemodel::Optics::HugeiconsIconBuilder < Rolemodel::Optics::SvgIconBuilder
  DEFAULT_STYLE = 'stroke-rounded'
  FILLED_STYLE = 'solid-rounded'
  DUOTONE_STYLE = 'duotone-rounded'

  attr_reader :style

  def self.default_root
    Rails.root.join('app/icons/hugeicons')
  end

  def self.flash_icons
    {
      notice: 'checkmark-circle-02',
      alert: 'cancel-circle'
    }
  end

  # The style a call renders, from an explicit style: or the filled:/duotone: flags.
  def self.style_for(style: nil, filled: false, duotone: false)
    return style if style.present?
    return DUOTONE_STYLE if duotone
    return FILLED_STYLE if filled

    DEFAULT_STYLE
  end

  def initialize(name, style: nil, **)
    super(name, **)
    @style = self.class.style_for(style:, filled:, duotone:)
  end

  private

  def svg_path
    self.class.path_for(style, name)
  end
end
