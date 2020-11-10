# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RegistrationOrder, type: :model do
  describe 'validations' do
    it 'requires the user' do
      registration_order = RegistrationOrder.new

      registration_order.valid?

      expect(registration_order.errors[:user]).to be_present
    end
  end

  describe 'scopes' do
    describe '.paid' do
      let!(:unpaid_order) { create(:registration_order, transaction_id: nil) }
      let!(:free_spectator) { create(:registration_order, :with_free_spectator, transaction_id: -1)}
      let!(:unpaid_free_spectator) { create(:registration_order, :with_free_spectator, transaction_id: nil)}
      let!(:paid_order) { create(:registration_order, transaction_id: '2319') }

      it 'returns only orders with a braintree transaction id' do
        expect(RegistrationOrder.paid).to contain_exactly(paid_order, free_spectator)
      end
    end

    describe '.order_by_user_names' do
      let!(:order1) { create(:registration_order, user: create(:user, name: 'second')) }
      let!(:order2) { create(:registration_order, user: create(:user, name: 'first')) }

      it 'returns orders sorted by the registration item users names' do
        expect(RegistrationOrder.order_by_user_names).to eq [order2, order1]
      end
    end
  end

  describe '#paid?' do
    it 'returns true if a transaction id is present' do
      registration_order = create(:registration_order)
      expect(registration_order).to be_paid
    end

    it 'returns false if a transaction id is not present' do
      registration_order = create(:registration_order, transaction_id: '')
      expect(registration_order).not_to be_paid
    end

    it 'returns true if it has a recorded price of 0' do
      registration_order = create(:registration_order, :with_free_spectator, purchase_total: 0, transaction_id: -1)
      expect(registration_order).to be_paid
    end

    it 'returns false if it has a price of 0, but has not been finalized' do
      registration_order = create(:registration_order, :with_free_spectator, transaction_id: nil)
      expect(registration_order).not_to be_paid
    end
  end

  describe '#finalize!' do
    describe 'for an order created with Braintree, but finalized with Stripe' do
      let(:mock_pricing) do
        OpenStruct.new(
          base_price: 10.00, total_convenience_fees: 0.99, total_price: 10.99,
          total_processing_fees: 0.00
        )
      end

      it 'updates the payment_processor to be correct' do
        order = build(:registration_order, payment_processor: 'braintree')

        order.finalize!('123', mock_pricing)
        expect(order.payment_processor).to eq 'stripe'
      end
    end

    describe 'zero dollar order' do
      let(:mock_pricing) do
        OpenStruct.new(
          base_price: 0, total_convenience_fees: 0, total_price: 0, total_processing_fees: 0)
      end

      it 'updates payment_processor to be blank' do
        order = build(:registration_order, payment_processor: 'braintree')
        order.finalize!(nil, mock_pricing)
        expect(order.payment_processor).to eq nil
      end
    end
  end

  describe 'promo code application' do
    let(:unpaid_order) { create(:registration_order, :with_registration_items, transaction_id: nil) }

    context 'price_percentage_adjustment' do
      it 'does not adjust athlete_price_percentage_adjustment without a valid promo code' do
        expect(unpaid_order.athlete_price_percentage_adjustment).to eq 1
      end

      it 'changes the price of the registration_item if a valid promo code' do
        unpaid_order.update(promotional_code: create(:promotional_code))
        expect(unpaid_order.athlete_price_percentage_adjustment).to eq 0.8
      end
    end

    context 'price_fixed_adjustment' do
      it 'does not adjust athlete_price_fixed_adjustment without a valid promo code' do
        expect(unpaid_order.athlete_price_fixed_adjustment).to eq 0
      end

      it 'changes the price of the registration_item if a valid promo code' do
        unpaid_order.update(promotional_code: create(:promotional_code, :fixed))
        expect(unpaid_order.athlete_price_fixed_adjustment).to eq 20
      end
    end
  end

  describe 'finding a promotional_code' do
    let(:irrelevant_registration_info) { create(:event_registration_info) }
    let(:irrelevant_promo_code) { create(:promotional_code, name:"ninjafit", adjustment_type: "percentage", adjustment: 0.9, event_registration_info: irrelevant_registration_info )}

    let(:unpaid_order) { create(:registration_order, :with_registration_items, transaction_id: nil) }
    let(:relevant_registration_info) { create(:event_registration_info, event: unpaid_order.event) }
    let(:relevant_promo_code) { create(:promotional_code, name:"ninjafit", adjustment_type: "percentage", adjustment: 0.7, event_registration_info: relevant_registration_info )}

    context 'where two promo codes have the same name' do
      it 'finds the promo code attached to the relevant event' do
        unpaid_order.update(promotional_code: relevant_promo_code)
        expect(unpaid_order.athlete_price_percentage_adjustment).to eq 0.7
        expect(relevant_promo_code.event_registration_info.event).not_to eq(irrelevant_promo_code.event_registration_info.event)
      end

      it 'finds the promo code attached to the irrelevant event' do
        unpaid_order.update(promotional_code: irrelevant_promo_code)
        expect(unpaid_order.athlete_price_percentage_adjustment).to eq 0.9
        expect(irrelevant_promo_code.event_registration_info.event).not_to eq(relevant_promo_code.event_registration_info.event)
      end
    end

    context 'where two events each have a promo codes' do
      let(:irrelevant_event) { irrelevant_registration_info.event }
      let(:relevant_event) { relevant_registration_info.event }

      before do
        irrelevant_event.update(registration_info: irrelevant_registration_info)
        relevant_event.update(registration_info: relevant_registration_info)
      end

      it 'seperates the two promo codes from each other' do
        expect(irrelevant_event.registration_info.promotional_codes).to eq([irrelevant_promo_code])
        expect(irrelevant_event.registration_info.promotional_codes).not_to eq([relevant_promo_code])

        expect(relevant_event.registration_info.promotional_codes).not_to eq([irrelevant_promo_code])
        expect(relevant_event.registration_info.promotional_codes).to eq([relevant_promo_code])
      end
    end
  end

  describe '#clear_unused_registration_items' do
    it 'removes all items that are not associated to the passed in season' do
      season = create :season
      other_season = create :season
      order = create :registration_order, :unpaid
      current_season_item = create :membership_item, registration_order: order, season: season
      other_season_item = create :membership_item, registration_order: order, season: other_season

      order.clear_unused_registration_items(season)

      expect(order.registration_items).to eq [current_season_item]
    end
  end

  describe '#pending_membership_for?' do
    let!(:order) { create :registration_order, :unpaid }
    let!(:athlete1) { create :athlete }
    let!(:athlete2) { create :athlete }

    context 'when there are membership items' do
      let(:season) { create :season }
      let!(:membership_item1) { create :membership_item, registration_order: order, season: season, athlete: athlete1 }
      let!(:membership_item2) { create :membership_item, registration_order: order, season: season }

      it 'returns true for athletes with membership items' do
        expect(order.pending_membership_for?(athlete1.id)).to eq true
        expect(order.pending_membership_for?(athlete2.id)).to eq false
      end
    end

    context 'when pending_membership_athlete_ids is set' do
      it 'returns true for athletes with in that list' do
        order.pending_membership_athlete_ids = [athlete2.id]

        expect(order.pending_membership_for?(athlete1.id)).to eq false
        expect(order.pending_membership_for?(athlete2.id)).to eq true
      end
    end

    context 'when neither pending_membership_athlete_ids or membership items exist' do
      it 'returns false' do
        expect(order.pending_membership_for?(athlete1.id)).to eq false
        expect(order.pending_membership_for?(athlete2.id)).to eq false
      end
    end
  end
end
