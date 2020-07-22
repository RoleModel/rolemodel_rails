# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Upgrading Subscription', :js do
  let(:organization) { create(:subscribed_organization) }
  let(:subscription) { organization.active_subscription }
  let(:user) { create(:user, :org_admin, organization: organization) }
  let(:mock_stripe_subscription) { build(:mock_stripe_subscription, plan_id: 'gym-yearly') }
  let(:proration_preview) { build(:mock_stripe_invoice, total: -249_26) }

  let(:league_gym_yearly) { 'plan_id_league-gym-yearly' }
  let(:league_gym_monthly) { 'plan_id_league-gym-monthly' }
  let(:gym_yearly) { 'plan_id_gym-yearly' }
  let(:gym_monthly) { 'plan_id_gym-monthly' }
  let(:individual_yearly) { 'plan_id_individual-yearly' }
  let(:individual_monthly) { 'plan_id_individual-monthly' }
  let(:participant_yearly) { 'plan_id_participant-yearly' }
  let(:participant_monthly) { 'plan_id_participant-monthly' }

  before do
    allow(Stripe::Subscription).to receive(:retrieve).and_return mock_stripe_subscription
    allow(Stripe::Invoice).to receive(:upcoming).with(
      subscription: mock_stripe_subscription.id,
      subscription_cancel_at: Date.current.end_of_day.to_i
    ).and_return proration_preview
    sign_in user
    visit edit_subscription_path
  end

  describe 'choosing a new plan' do
    it 'renders a form showing the current plan among other options', :js do
      expect(page).to have_content('Change Plan')
      expect(find_field(gym_yearly)).to be_checked # corresponds to factory
      expect(page).to have_button 'Replace Subscription' # presence b/c clickable test is too slow
    end

    it 'disables submit button if terms have not been acknowledged', :js do
      choose league_gym_monthly
      expect(page).to have_content('minimum 3 month term')
      expect(page).to have_button('Replace Subscription', disabled: true)
    end

    describe 'choosing an upgrade option' do
      let(:disclaimer) do
        'Your new plan will start now.' \
          ' Your card will be charged today' \
          ' and then recurrently according to your plan.'
      end

      it 'shows totals that include monetary credit for remaining time' do
        choose league_gym_yearly
        expect(page).to have_content('Upgrade Credit: $249.26')
        expect(page).to have_content('Total: $250.69')
        expect(page).to have_content('Future Billing Cycle Total: $499.95')
      end

      it 'has a disclaimer saying your new plan starts now and you get charged now' do
        choose league_gym_yearly
        expect(page).to have_content(disclaimer)

        choose league_gym_monthly
        expect(page).to have_content(disclaimer)
      end
    end

    describe 'choosing a downgrade option' do
      let(:disclaimer) do
        next_billing_date = subscription.next_billing_date.strftime('%B %-e, %Y')
        "Your new plan will start next billing cycle (#{next_billing_date})." \
          ' Your card will be charged on that date' \
          ' and then recurrently according to your plan.'
      end

      it 'shows totals without any monetary credit' do
        choose individual_yearly
        expect(page).to have_content('Upgrade Credit: $0.00')
        expect(page).to have_content('Total: $59.95')
        expect(page).to have_content('Future Billing Cycle Total: $59.95')

        choose individual_monthly
        expect(page).to have_content('Upgrade Credit: $0.00')
        expect(page).to have_content('Total: $5.99')
        expect(page).to have_content('Future Billing Cycle Total: $5.99')

        choose participant_yearly
        expect(page).to have_content('Upgrade Credit: $0.00')
        expect(page).to have_content('Total: $24.95')
        expect(page).to have_content('Future Billing Cycle Total: $24.95')

        choose participant_monthly
        expect(page).to have_content('Upgrade Credit: $0.00')
        expect(page).to have_content('Total: $2.49')
        expect(page).to have_content('Future Billing Cycle Total: $2.49')

        choose gym_yearly
        expect(page).to have_content('Upgrade Credit: $0.00')
        expect(page).to have_content('Total: $299.95')
        expect(page).to have_content('Future Billing Cycle Total: $299.95')

        choose gym_monthly
        expect(page).to have_content('Upgrade Credit: $0.00')
        expect(page).to have_content('Total: $29.99')
        expect(page).to have_content('Future Billing Cycle Total: $29.99')
      end

      it 'has a disclaimer saying your new plan will start at the end of cycle and you will be charged then' do
        choose individual_yearly
        expect(page).to have_content(disclaimer)

        choose individual_monthly
        expect(page).to have_content(disclaimer)

        choose participant_yearly
        expect(page).to have_content(disclaimer)

        choose participant_monthly
        expect(page).to have_content(disclaimer)

        choose gym_yearly
        expect(page).to have_content(disclaimer)

        choose gym_monthly
        expect(page).to have_content(disclaimer)
      end
    end
  end

  describe 'with a discontinued plan' do
    let(:mock_stripe_subscription) { build(:mock_stripe_subscription, plan_id: 'gym-quarterly') }

    it 'shows a warning message' do
      expect(page).to have_content 'no longer offered'

      mock_stripe_subscription.plan.id = 'gym-yearly'
      visit edit_subscription_path

      expect(page).to have_no_content 'no longer offered'
    end
  end
end
