require 'rails_helper'

RSpec.describe PaymentSource, type: :model do
  describe '#connected_account' do
    let(:organization_account) { build(:mock_stripe_account) }
    let(:league_admin_account) { build(:mock_stripe_account) }
    let(:season) { create :season, :for_unaa_league }
    let(:league_admin) { create :user, :unaa_admin }

    it 'returns the event organizations account' do
      registration_order = create :registration_order
      allow(registration_order.event.organization).to receive(:stripe_connect_account).and_return(organization_account)

      source = PaymentSource.new(registration_order.user, 'tok_visa')

      expect(source.connected_account(registration_order)).to eq organization_account
    end

    it 'returns the league admins account' do
      registration_order = create :registration_order, event: nil
      create :membership_item, season: season, registration_order: registration_order
      allow(registration_order.season.league.organization).to receive(:stripe_connect_account).and_return(league_admin_account)

      source = PaymentSource.new(registration_order.user, 'tok_visa')

      expect(source.connected_account(registration_order)).to eq league_admin_account
    end
  end
end
