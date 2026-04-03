# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Tools::Sample do
  describe '.call' do
    it 'returns a hash with expected fields' do
      result = described_class.call(name: 'Alice', server_context: {})

      expect(result).not_to be_error

      expect(result.structured_content).to have_key(:sample)
    end
  end
end
