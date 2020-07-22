# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Canceling Subscription' do
  let(:organization) { create(:organization) }
  let!(:subscription) { create(:subscription, organization: organization) }
  let(:user) { create(:user, :org_admin, organization: organization) }
  let(:mock_stripe_subscription) { build(:mock_stripe_subscription) }
  let(:mock_stripe_invoice) { build(:mock_stripe_invoice) }

  before :each do
    allow(Stripe::Subscription).to receive(:retrieve).and_return mock_stripe_subscription
    allow(Stripe::Invoice).to receive(:upcoming).and_return mock_stripe_invoice
    allow(mock_stripe_subscription).to receive(:delete) do
      mock_stripe_subscription.status = 'canceled'
    end
    sign_in user
    visit edit_subscription_path
  end

  def notice
    find('#notice')
  end

  describe 'canceling your plan', :js do
    it 'has a link for canceling your subscription' do
      expect(page).to have_content('Change Plan')
      click_on 'Cancel Subscription'
      expect(page).to have_current_path organization_path
      expect(notice).to have_text 'Subscription canceled successfully'
      expect(page).to have_text 'This subscription has been canceled. You will not be charged for it in the future.'
    end

    it 'confirms that you want to cancel your subscription', :js do
      expect(page).to have_content('Change Plan')
      click_on 'Cancel Subscription'
      expect(page).to have_current_path organization_path
      expect(notice).to have_text 'Subscription canceled successfully'
      expect(page).to have_text 'This subscription has been canceled. You will not be charged for it in the future.'
    end
  end
end
