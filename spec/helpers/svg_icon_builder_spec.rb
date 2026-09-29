# frozen_string_literal: true


require 'action_view'
require 'erb'
require 'tmpdir'
require 'rolemodel/optics'

RSpec.describe Rolemodel::Optics::HugeiconsIconBuilder, type: :helper do
  include ActionView::Helpers

  around do |example|
    Dir.mktmpdir do |dir|
      described_class.root = dir
      described_class.clear_cache
      %w[stroke-rounded solid-rounded duotone-rounded].each do |style|
        FileUtils.mkdir_p(File.join(dir, style))
        File.write(File.join(dir, style, 'home-01.svg'),
                   %(<svg viewBox="0 0 24 24" data-style="#{style}"><path/></svg>\n))
      end
      example.run
    ensure
      described_class.root = nil
    end
  end

  def render(name = 'home-01', **options) = described_class.new(name, **options).build

  it 'inlines the stroke-rounded SVG inside a decorative Optics icon span' do
    expect(render).to eq(
      '<span class="icon--svg icon" aria-hidden="true">' \
      '<svg aria-hidden="true" viewBox="0 0 24 24" data-style="stroke-rounded"><path/></svg></span>'
    )
  end

  it 'labels the icon when it has its own hover text' do
    expect(render(hover_text: 'Home'))
      .to start_with('<span class="icon--svg icon" role="img" aria-label="Home" title="Home">')
  end

  it 'maps filled and duotone to Hugeicons styles, and lets style: win' do
    expect(render(filled: true)).to include('data-style="solid-rounded"')
    expect(render(duotone: true)).to include('data-style="duotone-rounded"')
    expect(render(duotone: true, style: 'stroke-rounded')).to include('data-style="stroke-rounded"')
  end

  it 'adds the Optics size, weight, emphasis and color' do
    html = render(size: 'large', weight: 'bold', emphasis: 'low', color: 'primary')

    expect(html).to include('class="icon--svg icon--weight-bold icon--low-emphasis icon icon--large"')
    expect(html).to include('style="color: var(--op-color-primary-base);"')
  end

  it 'raises with the path when an icon is not vendored' do
    expect { render('missing-icon') }.to raise_error(Rolemodel::Optics::SvgIconBuilder::MissingIcon, /missing-icon/)
  end

  it 'refuses names that could leave the icon folder' do
    expect { render('../secrets') }.to raise_error(ArgumentError)
    expect { render('home-01', style: '../..') }.to raise_error(ArgumentError)
  end
end

RSpec.describe Rolemodel::Optics::Hugeicons do
  describe '.used_in' do
    it 'finds literal names with their style, including ternaries, and skips comments' do
      source = <<~SLIM
        = icon('add-01', size: 'small')
        = icon 'home-01', duotone: true
        = icon(up ? 'arrow-up-03' : 'arrow-down-03', style: 'twotone-rounded')
        = link_to icon('star', filled: true), root_path
        = flash_icon(:notice)
        -# = icon('commented-out')
      SLIM

      expect(described_class.used_in(source)).to contain_exactly(
        %w[add-01 stroke-rounded], %w[home-01 duotone-rounded], %w[arrow-up-03 twotone-rounded],
        %w[arrow-down-03 twotone-rounded], %w[star solid-rounded]
      )
    end
  end

  describe '.parse' do
    it 'defaults to stroke-rounded' do
      expect(described_class.parse('home-01, duotone-rounded/user')).to eq(
        [%w[home-01 stroke-rounded], %w[user duotone-rounded]]
      )
    end
  end

  describe '.normalize' do
    it 'turns colors into currentColor and keeps none' do
      svg = '<svg fill="none"><path stroke="#141B34" stroke-width="1.5"/><path fill="black"/></svg>'

      expect(described_class.normalize(svg))
        .to eq('<svg fill="none"><path stroke="currentColor" stroke-width="1.5"/><path fill="currentColor"/></svg>')
    end
  end

  describe '.extract_svg' do
    it 'reads raw SVG or SVG nested in JSON' do
      expect(described_class.extract_svg('<svg/>')).to eq('<svg/>')
      expect(described_class.extract_svg('{"data":{"svg":"<svg/>"}}')).to eq('<svg/>')
      expect(described_class.extract_svg('{"data":{}}')).to be_nil
    end
  end

  describe '.fetch' do
    it 'needs a token' do
      expect { described_class.fetch('home-01', style: 'stroke-rounded', token: nil) }
        .to raise_error(described_class::Error, /HUGEICONS_API_KEY/)
    end
  end
end
