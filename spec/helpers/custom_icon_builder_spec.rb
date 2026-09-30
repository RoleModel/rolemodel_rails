# frozen_string_literal: true

require 'action_view'
require 'rolemodel/optics'

RSpec.describe Rolemodel::Optics::CustomIconBuilder, type: :helper do
  let(:svg) { '<svg viewBox="0 0 24 24"><path stroke="currentColor" stroke-width="1.5"></path></svg>' }
  let(:builder) { described_class.new('duotone-rounded/home-01', hover_text: nil, **options) }
  let(:options) { {} }

  context 'with Propshaft' do
    before do
      asset = double(content: svg.dup.force_encoding('ASCII-8BIT'))
      load_path = double
      allow(load_path).to receive(:find).with('icons/duotone-rounded/home-01.svg').and_return(asset)
      allow(Rails).to receive(:application).and_return(double(assets: double(load_path:)))
    end

    it 'inlines the SVG inside an Optics svg-icon' do
      expect(builder.build).to eq("<span class=\"svg-icon icon\">#{svg}</span>")
    end

    context 'with weight and emphasis' do
      let(:options) { { weight: 'bold', emphasis: 'low', size: 'large' } }

      it 'adds the Optics modifiers' do
        expect(builder.build).to include('class="svg-icon icon--weight-bold icon--low-emphasis icon icon--large"')
      end
    end
  end

  context 'with Sprockets' do
    before do
      manifest = double
      sources = [double(source: svg)]
      allow(manifest).to receive(:find_sources).with('icons/duotone-rounded/home-01.svg').and_return(sources)
      allow(Rails).to receive(:application).and_return(double(assets: nil, assets_manifest: manifest))
    end

    it 'inlines the SVG' do
      expect(builder.build).to eq("<span class=\"svg-icon icon\">#{svg}</span>")
    end
  end

  context 'when the file is missing' do
    before do
      load_path = double(find: nil)
      allow(Rails).to receive(:application).and_return(double(assets: double(load_path:)))
    end

    it 'renders a comment naming the path' do
      expect(builder.build).to include('<!-- SVG icons/duotone-rounded/home-01.svg not found -->')
    end
  end
end
