# frozen_string_literal: true

require 'concurrent/map'

# SvgIconBuilder is an IconBuilder that inlines SVG files the application keeps in its own repo.
# It reads each file from disk once per process, so rendering needs no asset pipeline, API or CDN.
#
#   app/icons/<name>.svg  => icon('name')
#
# The files live outside app/assets on purpose: the asset pipeline would publish each one as a
# downloadable file, which licensed sets (Hugeicons Pro) do not allow.
#
# Subclasses change where the files live (see HugeiconsIconBuilder).
class Rolemodel::Optics::SvgIconBuilder < Rolemodel::Optics::IconBuilder
  class MissingIcon < StandardError; end

  IDENTIFIER = /\A[a-z0-9-]+\z/
  SVGS = Concurrent::Map.new

  class << self
    attr_writer :root

    # The directory that holds this set's SVG files. Set it in an initializer to use another folder:
    #   Rolemodel::Optics::HugeiconsIconBuilder.root = Rails.root.join('vendor/huge_icons')
    def root
      @root || default_root
    end

    def default_root
      Rails.root.join('app/icons')
    end

    def flash_icons
      {
        notice: 'circle-check',
        alert: 'circle-x'
      }
    end

    # The file for an icon. Names come from views, so only [a-z0-9-] is allowed in a path segment.
    def path_for(*segments)
      validate!(*segments)
      Pathname(root).join(*segments[0...-1], "#{segments.last}.svg")
    end

    def validate!(*segments)
      segments.each do |segment|
        raise ArgumentError, "Invalid icon identifier: #{segment}" unless segment.to_s.match?(IDENTIFIER)
      end
    end

    # The <svg> itself is always hidden from assistive technology; the wrapping span is labelled.
    def prepare(svg)
      svg.strip.sub('<svg', '<svg aria-hidden="true"')
    end

    def clear_cache
      SVGS.clear
    end
  end

  # An icon with its own hover_text is meaningful: the span becomes an image named by that text.
  # One that only repeats its name is decorative and is hidden, so screen readers skip "home-01".
  def build
    options = { class: tag_classes.compact_blank.join(' '), style: color_style }.compact_blank
    options.merge!(decorative? ? { aria: { hidden: true } } : { role: 'img', aria: { label: hover_text },
                                                                title: hover_text })

    tag.span(tag_contents, **options)
  end

  private

  def decorative?
    hover_text.blank? || hover_text == name
  end

  def color_style
    "color: var(--op-color-#{color}-base);" if color.present?
  end

  def tag_contents
    path = svg_path
    svg = if cache?
            SVGS.compute_if_absent(path.to_s) { self.class.prepare(path.read) }
          else
            self.class.prepare(path.read)
          end

    # These SVG files are part of this app's code, reviewed in the commit that adds them.
    svg.html_safe
  rescue Errno::ENOENT
    missing_icon(path)
  end

  def tag_classes
    [
      'icon--svg',
      weight == DEFAULT_WEIGHT ? '' : "icon--weight-#{weight}",
      emphasis == DEFAULT_EMPHASIS ? '' : "icon--#{emphasis}-emphasis"
    ].concat(super)
  end

  def svg_path
    self.class.path_for(name)
  end

  # Re-read files while the app reloads code, so a newly edited SVG shows up without a restart.
  def cache?
    !(defined?(Rails.application) && Rails.application&.config&.enable_reloading)
  end

  def missing_icon(path)
    raise MissingIcon, "Icon #{name} not found at #{path}" unless defined?(Rails.env) && Rails.env.production?

    "<!-- Icon #{ERB::Util.html_escape(name)} not found -->".html_safe
  end
end
