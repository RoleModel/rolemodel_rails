require 'rails_helper'

RSpec.describe EventRegistrationInfo, type: :model do

  describe 'validations' do
    let(:event_registration_info) { build :event_registration_info }

    it 'is valid' do
      expect(event_registration_info).to be_valid
    end

    it 'must have an event_registration_info' do
      event_registration_info.event = nil
      expect(event_registration_info.valid?).to be false
    end

    it 'must have a price' do
      event_registration_info.price = nil
      expect(event_registration_info.valid?).to be false
    end

    context 'banner' do
      it 'only allows image files' do
        attach_invalid_photo(event_registration_info)
        expect(event_registration_info).not_to be_valid
        expect(event_registration_info.errors[:banner]).to include 'must be an image file'
        expect(ActiveStorage::Blob.count).to eq 0
        expect(ActiveStorage::Attachment.count).to eq 0
        # expect(event_registration_info.photo).not_to be_attached
      end

      it 'updating only allows image files' do
        event_registration_info.save
        io_stream = fixture_file_upload(Rails.root + 'spec/fixtures/photos/test-banner-photo.tif')

        event_registration_info.update(photo: io_stream)
        expect(event_registration_info).not_to be_valid
        expect(event_registration_info.errors[:banner]).to include 'must be an image file'
        expect(ActiveStorage::Blob.count).to eq 0
        expect(ActiveStorage::Attachment.count).to eq 0
        # expect(event_registration_info.photo).not_to be_attached
      end

      it 'does not allow files over 10mb' do
        attach_large_photo(event_registration_info)
        expect(event_registration_info).not_to be_valid
        expect(event_registration_info.errors[:banner]).to include 'must be smaller than 10mb'
        expect(ActiveStorage::Blob.count).to eq 0
        expect(ActiveStorage::Attachment.count).to eq 0
        # expect(event_registration_info.photo).not_to be_attached
      end
    end
  end

  describe 'address' do
    let(:event_registration_info) { build :event_registration_info }
    let(:address) { '123 main st.' }
    let(:address_2) { 'Am I Set?' }

    it "provides event address if it has one" do
      event_registration_info.update(address: address_2)
      expect(event_registration_info.address).to eq(address_2)
    end

    it "provides organization address if it doesn't have its own" do
      event_registration_info.event.organization.update(address: address)
      expect(event_registration_info.address).to eq(address)
    end
  end

  describe '#price_of' do
    let(:event) { create :event, :with_tags }
    let(:event_registration_info) { create :event_registration_info, event: event }
    let(:registration_order) { create :registration_order, event: event }
    let(:contestant_item_first_group) { create(:contestant_item, registration_order: registration_order, tags: "#{event.tag_config[:classes].first} #{event.tag_config[:gender].first}") }
    let(:contestant_item_last_group) { create(:contestant_item, registration_order: registration_order, tags: "#{event.tag_config[:classes].last} #{event.tag_config[:gender].last}") }

    it 'defaults to something greater than zero' do
      expect(event_registration_info.price).to be > 0
    end

    it 'gives the default price for a registration_item' do
      expect(event_registration_info.price_of(contestant_item_first_group)).to eq event_registration_info.price
    end

    context 'with variations' do
      let(:contestant_item_first_class_group) { create(:contestant_item, registration_order: registration_order, tags: "#{event.tag_config[:classes].first} #{event.tag_config[:gender].last}") }

      let!(:first_variation) { create(:price_variation, event_registration_info: event_registration_info, tags: [event.tag_config[:classes].first, event.tag_config[:gender].first], price: 40.0) }
      let!(:second_variation) { create(:price_variation, event_registration_info: event_registration_info, tags: [event.tag_config[:classes].first], price: 25.0) }

      it 'gives the variation price for a registration_item with all the matching tags' do
        expect(event_registration_info.price_of(contestant_item_first_group)).to eq first_variation.price
      end

      it 'gives the second variation price for a registration_item with only the first tag' do
        expect(event_registration_info.price_of(contestant_item_first_class_group)).to eq second_variation.price
      end

      it 'gives the default price for a registration_item without any matching tags' do
        expect(event_registration_info.price_of(contestant_item_last_group)).to eq event_registration_info.price
      end
    end
  end

  describe 'promo_codes' do
    let(:event_registration_info) { build :event_registration_info }

    context '#includes_promo_code?' do
      let(:promotional_code) do
        create :promotional_code, :fixed, event_registration_info: event_registration_info
      end
      let(:percentage_promotional_code) do
        create :promotional_code, event_registration_info: event_registration_info
      end
      let(:upcased_promo_code) do
        create :promotional_code, name: 'FAITh', event_registration_info: event_registration_info
      end

      it 'returns true if promo_code is valid for this event' do
        expect(event_registration_info.includes_promo_code?(promotional_code)).to be true
        expect(event_registration_info.includes_promo_code?(percentage_promotional_code)).to be true
        expect(event_registration_info.includes_promo_code?(upcased_promo_code)).to be true
      end

      it 'returns false if promo_code is not valid for this event' do
        expect(event_registration_info.includes_promo_code?('works')).to be false
      end
    end
  end

end
