# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PromotionalCode, type: :model do
  let!(:promotional_code) { create :promotional_code }

  describe 'validations' do
    it 'requires the name, adjustment_type, and adjustment' do
      code = PromotionalCode.new

      code.valid?

      expect(code.errors[:name]).to be_present
      expect(code.errors[:adjustment_type]).to be_present
      expect(code.errors[:adjustment]).to be_present
    end
  end

  describe '#name=' do
    it 'cleans names passed in' do
      promotional_code1 = create :promotional_code, name: '  Bob SAGET is CoOl'
      promotional_code2 = create :promotional_code, name: 'Will this clean up trailing?     '

      expect(promotional_code1.name).to eq 'bob saget is cool'
      expect(promotional_code2.name).to eq 'will this clean up trailing?'
    end
  end
end
