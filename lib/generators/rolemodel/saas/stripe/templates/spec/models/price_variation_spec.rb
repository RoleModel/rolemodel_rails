require 'rails_helper'

RSpec.describe PriceVariation, type: :model do

  describe 'validations' do
    let(:variation) { build :price_variation }

    it 'must have a price' do
      variation.price = nil
      expect(variation.valid?).to be false
    end

    it 'must have a name' do
      variation.name = nil
      expect(variation).not_to be_valid
    end

    it 'must have an event_registration_info' do
      variation.event_registration_info = nil
      expect(variation.valid?).to be false
    end

    it 'must have tags' do
      variation.tags = nil
      expect(variation.valid?).to be false
    end
  end

  describe '#position' do
    let(:registration_info) { create :event_registration_info }
    let(:first_price_variation) { create :price_variation, event_registration_info: registration_info }
    let(:second_price_variation) { create :price_variation, event_registration_info: registration_info }

    it 'initially corresponds to creation order on the registration_info' do
      expect(first_price_variation.position).to eq(1)
      expect(second_price_variation.position).to eq(2)
    end
  end

  describe '#match' do
    let(:variation) { build(:price_variation, tags: %w[male 6-7 unaa]) }

    context 'returns true' do
      it 'if all the variation tags are in the registration item' do
        registration_item = build(:contestant_item, tags: 'male 6-7 unaa')
        expect(variation.match(registration_item)).to be true
      end

      it 'if more than the variation tags are in the registration item' do
        registration_item = build(:contestant_item, tags: 'male 6-7 unaa custom-tag')
        expect(variation.match(registration_item)).to be true
      end
    end

    context 'returns false' do
      it 'if not all the variation tags are in the registration item' do
        registration_item = build(:contestant_item, tags: 'male unaa')
        expect(variation.match(registration_item)).to be false
      end

      it 'if some variation tags are in the registration item' do
        registration_item = build(:contestant_item, tags: 'male 8-10 unaa')
        expect(variation.match(registration_item)).to be false
      end

      it 'if no tags are in the registration item' do
        registration_item = build(:contestant_item, tags: '')
        expect(variation.match(registration_item)).to be false
      end
    end
  end
end
