# frozen_string_literal: true

require 'json'
require 'net/http'

# Vendors Hugeicons SVGs into the app, so rendering never calls the Hugeicons API.
#
# Only adding an icon needs HUGEICONS_API_KEY, the "Universal license token" from the Hugeicons
# dashboard. Pro styles need a Pro seat for each developer who commits them. Pro SVGs stay in the
# app's private repo, outside app/assets: never in a public gem or package, never a public download.
# Free: stroke-rounded (MIT). Pro: solid, duotone, twotone, bulk and the sharp/standard variants.
#
#   bin/rails optics:icons:vendor                                  # every icon the app uses but lacks
#   bin/rails optics:icons:vendor ICONS=home-01,duotone-rounded/user
module Rolemodel::Optics::Hugeicons
  API_URL = 'https://api.hugeicons.com/v1'
  TOKEN_ENV = %w[HUGEICONS_API_KEY HUGE_ICONS_TOKEN HUGEICONS_TOKEN].freeze
  SOURCES = 'app/**/*.{rb,erb,slim,haml}'
  COMMENT = %r{\A\s*(#|-#|/)}
  ICON_CALL = /\bicon(?:\(|\s+(?=['"]))(?<args>[^\n]*)/

  class Error < StandardError; end

  module_function

  def builder = Rolemodel::Optics::HugeiconsIconBuilder

  # Writes each icon to the builder's folder. icons: [[name, style], ...]
  def vendor(icons, token: api_token, out: $stdout)
    icons.map do |name, style|
      path = builder.path_for(style, name)
      path.dirname.mkpath
      path.write("#{normalize(fetch(name, style:, token:))}\n")
      out.puts "vendored #{path}"
      path
    end
  end

  # "home-01,duotone-rounded/user" => [['home-01', 'stroke-rounded'], ['user', 'duotone-rounded']]
  def parse(list)
    list.to_s.split(',').map(&:strip).compact_blank.map do |entry|
      style, name = entry.include?('/') ? entry.split('/', 2) : [builder::DEFAULT_STYLE, entry]
      [name, style]
    end
  end

  # Icons the app names with a literal string, as [name, style] pairs. A name built at runtime is
  # invisible here; vendor it by hand with ICONS=style/name.
  def used(root: Rails.root)
    Dir.glob(Pathname(root).join(SOURCES)).flat_map { |file| used_in(File.read(file)) }.uniq.sort
  end

  def used_in(source)
    source = source.lines.grep_v(COMMENT).join
    source.to_enum(:scan, ICON_CALL).flat_map do
      name_part, options = Regexp.last_match(:args).split(/,\s*(?=[a-z_]+:)/, 2)
      style = style_in(options.to_s)
      name_part.to_s.scan(/['"]([a-z0-9-]+)['"]/).flatten.map { [it, style] }
    end
  end

  def style_in(options)
    builder.style_for(
      style: options[/style:\s*['"]([a-z0-9-]+)['"]/, 1],
      filled: options.match?(/filled:\s*true/),
      duotone: options.match?(/duotone:\s*true/)
    )
  end

  def missing(root: Rails.root)
    used(root:).reject { |name, style| builder.path_for(style, name).exist? }
  end

  # Colors become currentColor so an icon follows the text color. `none` stays, so outlines stay
  # outlines. Stroke widths stay on the paths; Optics' weight modifiers override them with CSS.
  def normalize(svg)
    svg.strip.gsub(/(fill|stroke)="(?!none\b)[^"]+"/i, '\1="currentColor"')
  end

  def fetch(name, style:, token: api_token)
    builder.validate!(style, name)
    raise Error, "Set #{TOKEN_ENV.first} to vendor Hugeicons" if token.blank?

    response = get("icon/#{name}/svg", { style: }, token.strip)
    raise Error, "Hugeicons #{style}/#{name}: HTTP #{response.code}" unless response.is_a?(Net::HTTPSuccess)

    extract_svg(response.body) || raise(Error, "Hugeicons #{style}/#{name}: no SVG in the response")
  end

  # Hugeicons documents the x-api-key header; the Bearer header keeps older tokens working.
  def get(path, params, token)
    uri = URI("#{API_URL}/#{path}")
    uri.query = URI.encode_www_form(params)
    request = Net::HTTP::Get.new(uri, 'x-api-key' => token, 'Authorization' => "Bearer #{token}")
    Net::HTTP.start(uri.host, uri.port, use_ssl: true) { it.request(request) }
  end

  # The API answers with raw SVG or with JSON that holds it.
  def extract_svg(body)
    return body if body.lstrip.start_with?('<svg')

    find_svg(JSON.parse(body))
  rescue JSON::ParserError
    nil
  end

  def find_svg(value)
    case value
    when String then value if value.lstrip.start_with?('<svg')
    when Array then value.filter_map { find_svg(it) }.first
    when Hash then value.values.filter_map { find_svg(it) }.first
    end
  end

  def api_token
    TOKEN_ENV.filter_map { ENV[it].presence }.first
  end
end
