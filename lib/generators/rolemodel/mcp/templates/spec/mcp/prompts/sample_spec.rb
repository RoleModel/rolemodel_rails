# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Prompts::Sample do
  describe '.template' do
    subject(:result) { described_class.template({}) }

    it 'has the correct description' do
      expect(result.messages.length).to eq(1)
      expect(result.messages.first.role).to eq('assistant')
      expect(result.description).to include('Sample prompt result description')
    end
  end
end
