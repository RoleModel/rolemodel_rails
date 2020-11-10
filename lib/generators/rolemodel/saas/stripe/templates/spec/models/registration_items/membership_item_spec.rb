require 'rails_helper'

RSpec.describe MembershipItem do
  context '#register_athlete' do
    let(:season) { create(:season, :for_unaa_league) }
    let(:athlete) { create :athlete }
    let(:membership_item) { create :membership_item, season: season, athlete: athlete }

    it 'creates a new membership for an athlete' do
      expect{ membership_item.register_athlete }.to(change{ athlete.league_memberships.count }.from(0).to(1))
    end

    it 'does not create a membership if one exists for the season and athlete' do
      create :league_membership, athlete: athlete, season: season
      expect{ membership_item.register_athlete }.not_to(change{ athlete.league_memberships.count })
    end
  end
end
