# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Resources::DocsController do
  describe 'class methods' do
    it 'returns the correct values' do
      expect(described_class.schema).to eq('docs://')
      expect(described_class.mime_type).to eq('text/markdown')
    end
  end

  describe '.resource_list' do
    it 'registers the sample resource' do
      expect(described_class.resource_list.map(&:uri)).to contain_exactly('docs://SAMPLE_DOC.md')
    end
  end

  describe 'validations' do
    it 'is valid for a known docs resource' do
      controller = described_class.new('SAMPLE_DOC.md')

      expect(controller).to be_valid
    end

    it 'is invalid for an unknown docs resource' do
      controller = described_class.new('missing-doc')

      expect(controller).not_to be_valid
      expect(controller.errors[:file_path]).to eq(['Unknown docs resource: missing-doc'])
    end

    it 'is invalid when the mapped file is missing' do
      stub_const(
        'Resources::DocsController::FILES',
        { 'SAMPLE_DOC.md' => Rails.root.join('app/mcp/resources/docs/missing.md') }.freeze
      )

      controller = described_class.new('SAMPLE_DOC.md')

      expect(controller).not_to be_valid
      expect(controller.errors[:file_path]).to eq(['Missing docs file for SAMPLE_DOC.md'])
    end
  end

  describe '#serve' do
    it 'returns the markdown for the requested docs resource' do
      controller = described_class.new('SAMPLE_DOC.md')

      content = controller.serve

      expect(content).to include('# Hello World')
    end
  end
end
