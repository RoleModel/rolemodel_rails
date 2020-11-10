# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ticket, type: :model do
  describe 'validations' do
    let(:ticket) { Ticket.new }
    it 'requires the name' do
      ticket.valid?
      expect(ticket.errors[:name]).to be_present
    end

    it 'requires the price' do
      ticket.valid?
      expect(ticket.errors[:price]).to be_present
    end

    it 'accepts a price of $0' do
      ticket.price = 0
      ticket.valid?
      expect(ticket.errors[:price]).not_to be_present
    end

    it 'requires the event' do
      ticket.valid?
      expect(ticket.errors[:event]).to be_present
    end
  end

  describe '#comment' do
    let(:ticket) { create :ticket, name: 'Spectator', price: 10.66 }

    it 'starts out blank' do
      expect(ticket.comment).to be_blank
    end
  end

  describe '.registration_item_for_event' do
    let(:user) { create(:user) }
    let(:event) { create(:event, :with_tags, name: 'Good Event') }
    let(:other_event) { create(:event, :with_tags, name: 'Bad Event') }

    let(:ticket) { create :ticket, name: 'Spectator', price: 10.66 , event: event }

    let(:unpaid_order) { create(:registration_order, :unpaid, event: event, user: user) }

    let(:bad_order) { create(:registration_order, :unpaid, event: event, user: user) }
    let!(:bad_item) { create(:ticket_item, registration_order: bad_order, ticket: ticket) }

    it 'does not return items for a different order' do
      expect(ticket.registration_item_for_event(unpaid_order)).to eq nil
    end

    context 'with valid item on order' do
      let!(:good_item) { create(:ticket_item, registration_order: unpaid_order, ticket: ticket) }

      it 'returns items in a given event' do
        expect(ticket.registration_item_for_event(unpaid_order)).to eq good_item
      end
    end
  end

  describe '#as_json' do
    let(:user) { create(:user) }
    let(:event) { create(:event, :with_tags, name: 'UBW!') }
    let(:ticket) { create :ticket, name: 'Spectator', price: 23.19 , event: event }
    let(:unpaid_order) { create(:registration_order, :unpaid, event: event, user: user) }
    let!(:good_item) { create(:ticket_item, registration_order: unpaid_order, ticket: ticket) }

    it 'returns a ticket as json' do
      result = ticket.as_json.with_indifferent_access

      expect(result[:id]).to eq ticket.id
      expect(result[:comment]).to eq ticket.comment
      expect(result[:event_id]).to eq ticket.event_id
      expect(result[:name]).to eq ticket.name
      expect(result[:price]).to eq ticket.price.to_s
      expect(result).not_to have_key(:registration_item)
    end

    it 'uses registration_item_for_event if option passed' do
      result = ticket.as_json(registration_item_for_order: unpaid_order).with_indifferent_access

      expect(result[:registration_item]).to eq good_item
    end
  end
end
