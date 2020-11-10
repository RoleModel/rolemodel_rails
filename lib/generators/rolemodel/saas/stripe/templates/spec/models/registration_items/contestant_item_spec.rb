require 'rails_helper'

RSpec.describe ContestantItem do
  describe '#athlete_base_price' do
    let(:contestant_item) { create :contestant_item, tags: 'adults male' }
    let(:event_registration_info) { contestant_item.event.event_registration_info }

    context 'when there is a league discount' do
      before do
        allow(contestant_item).to receive(:league_member_discount?).and_return(true)
      end

      it 'returns the registration info price with the discount taken off' do
        price = event_registration_info.price - EventRegistrationInfo::UNAA_LEAGUE_MEMBER_DISCOUNT

        expect(contestant_item.athlete_base_price).to eq price
      end

      it 'returns zero if the price will be negative' do
        event_registration_info.update(price: EventRegistrationInfo::UNAA_LEAGUE_MEMBER_DISCOUNT - 5)

        expect(contestant_item.athlete_base_price).to eq 0
      end
    end

    context 'when there is no league discount' do
      it 'returns the registration info price' do
        expect(contestant_item.athlete_base_price).to eq event_registration_info.price
      end
    end
  end

  describe '#league_member_discount?' do
    let(:athlete) { create :athlete }
    let(:contestant_item) { create :contestant_item, athlete: athlete, tags: 'adults male' }
    let(:order) { contestant_item.registration_order }

    context 'when the event offers league member discounts' do
      before do
        contestant_item.event.event_registration_info.update(league_member_discount: true)
      end

      it 'returns true when the athlete is a member of the league' do
        season = create :season, :for_unaa_league
        sanction = create :sanction, season: season
        contestant_item.event.update(sanction: sanction, tag_config: season.tag_config)
        create :league_membership, athlete: athlete, season: season

        expect(contestant_item.league_member_discount?).to eq true
      end

      it 'returns true when the athlete is about to become a member' do
        order.pending_membership_athlete_ids = [athlete.id]

        expect(contestant_item.league_member_discount?).to eq true
      end
    end

    context 'when the event does not offer league member discounts' do
      it 'returns false' do
        expect(contestant_item.league_member_discount?).to eq false
      end
    end
  end
end
