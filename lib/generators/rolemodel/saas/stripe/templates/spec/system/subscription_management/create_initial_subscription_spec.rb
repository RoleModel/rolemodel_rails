# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Creating Initial Subscription' do
  let(:user) { create(:user, :org_admin) }
  let(:event) { create(:scheduled_event, event_contestant_count: 0, organization: user.organization) }

  it 'allows a user to skip adding a subscription', :js do
    sign_in user
    visit new_subscription_path

    click_on 'Skip Subscription'

    expect(page).to have_current_path events_path
  end

  describe 'filling out the creation form', :js do
    let(:league_gym_yearly) { 'plan_id_league-gym-yearly' }
    let(:league_gym_monthly) { 'plan_id_league-gym-monthly' }
    let(:gym_yearly) { 'plan_id_gym-yearly' }
    let(:gym_monthly) { 'plan_id_gym-monthly' }
    let(:individual_yearly) { 'plan_id_individual-yearly' }
    let(:individual_monthly) { 'plan_id_individual-monthly' }
    let(:participant_yearly) { 'plan_id_participant-yearly' }
    let(:participant_monthly) { 'plan_id_participant-monthly' }

    before :each do
      sign_in user
      visit new_subscription_path
    end

    def expect_started_subscription(path, contestants, credits)
      within_frame do
        Stripe::TestHelpers.fill_in_card_details(page)
      end
      click_on 'Start Subscription'

      expect(page).to have_current_path(path)
      expect(page).to have_text 'Subscription payment successful'

      organization = user.organization.reload
      expect(organization.stripe_customer_id).to be_present
      expect(organization.active_subscription).to be_present
      expect(organization.max_contestants).to eq contestants
      expect(organization.credits).to eq credits
    end

    context 'promotion codes', :vcr do
      let(:user) { create(:user, :org_admin, :with_stripe_customer) }

      it 'allows a user to apply a promotion code to league gym yearly' do
        # The promo code must match up with Stripe test mode coupon!!
        promotion_code = 'TEST-PROMO'
        stub_const("#{SubscriptionPlan}::ACTIVE_PROMOTIONS", {
          promotion_code => {
            'league-gym-yearly' => 100
          }
        })

        choose league_gym_yearly
        fill_in 'promotion_code', with: promotion_code
        expect_started_subscription(manage_events_path, Subscription::UNLIMITED_CONTESTANTS, SubscriptionPlan::LeagueGym.initial_credits)
        # Query Stripe for next amount w/ promotion applied
        next_bill_amount = user.organization.active_subscription.next_charge_amount
        expect(next_bill_amount).to eq 399.95
      end
    end

    it 'allows a user to log out instead' do
      find('.bm-burger-button').click
      click_on 'Log out'
      expect(page).to have_current_path root_path
      visit manage_events_path
      expect(page).to have_current_path new_user_session_path
    end

    it 'prevents a user from creating a subscription until they choose a plan' do
      # (forget to choose a plan...)
      within_frame do
        Stripe::TestHelpers.fill_in_card_details(page)
      end
      click_on 'Start Subscription'

      expect(page).to have_current_path new_subscription_path
      expect(page).to have_text 'Please select a plan to purchase a subscription'
      expect(user.organization.active_subscription.plan_category).to eq Subscription.default.plan_category
    end

    it 'prevents a user from clicking submit until there is valid card info' do
      choose league_gym_yearly
      click_on 'Start Subscription'
      expect(page).to have_current_path new_subscription_path
      expect(page).to have_text 'Your card number is incomplete'
    end

    it 'prevents a user from submitting again while they wait for the purchase to process', :js do
      # Don't let it move on after you submit... simulate controller taking forever to contact Braintree
      allow_any_instance_of(SubscriptionsController).to receive(:create)

      choose league_gym_yearly
      within_frame do
        Stripe::TestHelpers.fill_in_card_details(page)
      end
      click_on 'Start Subscription'
      expect(page).to have_button('Start Subscription', disabled: true)
    end
  end

  describe 'when the organization has no subscription' do
    it 'allows them basic access' do
      visit new_user_session_path
      fill_in 'Email', with: user.email
      fill_in 'Password', with: user.password
      click_on 'Log in'

      expect(page).to have_current_path events_path
    end
  end

  describe 'when the organization subscription is paid-up' do
    let!(:subscription) { create(:subscription, organization: user.organization, paid_through_date: Date.current + 1.month) }

    it 'allows page navigation to go through without redirects' do
      visit new_user_session_path
      fill_in 'Email', with: user.email
      fill_in 'Password', with: user.password
      click_on 'Log in'

      expect(page).to have_current_path manage_events_path

      paths = [manage_events_path, event_contestants_path(event)]

      paths.each do |path|
        visit path
        expect(page).to have_current_path path
      end
    end
  end
end
