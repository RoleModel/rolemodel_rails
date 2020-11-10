# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RegistrationItem, type: :model do
  describe 'validations' do
    it 'requires the registration_order, type, and quantity' do
      registration_item = RegistrationItem.new

      registration_item.valid?

      expect(registration_item.errors[:registration_order]).to be_present
      expect(registration_item.errors[:type]).to be_present
      expect(registration_item.quantity).to eq 1
    end

    it 'requires tickets to be available' do
      registration_item = create(:contestant_item, :with_tags)
      registration_item.event.registration_info.limit!(registration_item.tags.split.first, 0)
      registration_item.valid?
      expect(registration_item.errors[:tags]).to be_present
    end

    context 'type' do
      it 'requires the athlete and tags if contestant type' do
        registration_item = RegistrationItem.new(type: 'ContestantItem')

        registration_item.valid?

        expect(registration_item.errors[:athlete]).to be_present
        expect(registration_item.errors[:ticket]).not_to be_present
        expect(registration_item.errors[:tags]).to be_present
      end

      it 'requires the ticket if ticket type' do
        registration_item = RegistrationItem.new(type: 'TicketItem')

        registration_item.valid?

        expect(registration_item.errors[:ticket]).to be_present
        expect(registration_item.errors[:athlete]).not_to be_present
        expect(registration_item.errors[:tags]).not_to be_present
      end
    end

    describe '#unit_price' do
      context 'ticket' do
        let(:ticket) { create :ticket }
        let(:line_item) { create(:ticket_item, ticket: ticket) }

        it 'returns the price of the ticket' do
          expect(line_item.unit_price).to eq ticket.price
        end
      end

      context 'athlete' do
        let(:line_item) { create(:contestant_item, :with_tags) }

        context 'with percentage discounts' do
          it 'returns the registration info price ' do
            adjustment = 0.8
            allow(line_item.registration_order).to receive(:athlete_price_percentage_adjustment).and_return(adjustment)
            expect(line_item.unit_price).to eq adjustment * line_item.athlete_base_price
          end
        end

        context 'with fixed discounts' do
          it 'returns the registration info price ' do
            adjustment = 10
            allow(line_item.registration_order).to receive(:athlete_price_fixed_adjustment).and_return(adjustment)
            expect(line_item.unit_price).to eq line_item.athlete_base_price - adjustment
          end
        end

        context 'without discounts' do
          it 'returns the registration info price' do
            expect(line_item.unit_price).to eq line_item.athlete_base_price
          end
        end
      end
    end

    describe '#registration_price' do
      let(:event) { create(:event, :with_tags) }
      let!(:registration_info) { create(:event_registration_info, event: event, price: 45.00)}
      let(:order) { create(:registration_order, event: event) }
      let(:ticket) { create(:ticket, event: event, name: 'Spectator Ticket', price: 10.66) }
      let(:contestant_item) { create(:contestant_item, registration_order: order, tags: '6-7 male pro') }
      let(:ticket_item) { create(:ticket_item, ticket: ticket, quantity: 4, registration_order: order) }

      it 'returns the ticket price multiplied by the quantity if ticket' do
        expect(ticket_item.registration_price).to eq ticket.price * ticket_item.quantity
      end

      it 'returns the price based on registration_info if contestant' do
        expect(contestant_item.registration_price).to eq registration_info.price
      end

      context 'with variations' do
        let!(:variation) { create(:price_variation, event_registration_info: registration_info, tags: %w[pro 6-7], price: 100.0)}

        it 'returns the the price based on tags if contestant' do
          expect(contestant_item.registration_price).to eq variation.price
        end
      end
    end

    describe '#athlete_base_price' do
      let(:line_item) { create(:contestant_item, :with_tags) }

      it 'returns the event\'s price for that particular athlete' do
        event = line_item.registration_order.event
        expect(line_item.athlete_base_price).to eq event.event_registration_info.price_of(line_item)
      end
    end
  end

  describe 'refunds' do
    let(:event) { create(:event, :with_tags) }
    let!(:course) { create(:course, event: event) }
    let!(:registration_info) { create(:event_registration_info, event: event, price: 45.00)}
    let(:order) { create(:registration_order, event: event) }
    let(:ticket) { create(:ticket, event: event, name: 'Spectator Ticket', price: 10.66) }
    let(:contestant_item) { create(:contestant_item, :with_price, registration_order: order, tags: '6-7 male pro') }

    before do
      event.register_athlete(contestant_item.athlete, contestant_item.tags)
    end

    it 'is marked as refunded' do
      contestant_item.refund!

      expect(contestant_item).to be_refunded
    end

    it 'removes event contestants' do
      expect(event.event_contestants.count).to eq 1

      contestant_item.refund!

      expect(event.event_contestants.count).to eq 0
    end

    it 'keeps event contestants with run data associated' do
      create(:contestant_course_run, :started, event_contestant: event.event_contestants.first)
      expect(event.event_contestants.count).to eq 1

      contestant_item.refund!

      expect(event.event_contestants.count).to eq 1
    end
  end

  describe '#type_prefixed_name' do
    it 'handles all types' do
      membership_item = build :membership_item
      contestant_item = build :contestant_item
      ticket_item = build :ticket_item

      expect(membership_item.type_prefixed_name).to eq "Membership: #{membership_item.athlete.name}"
      expect(contestant_item.type_prefixed_name).to eq "Contestant: #{contestant_item.athlete.name}"
      expect(ticket_item.type_prefixed_name).to eq "Ticket: #{ticket_item.name}"
    end
  end
end
