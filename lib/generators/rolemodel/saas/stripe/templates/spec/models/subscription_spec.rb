require 'rails_helper'

RSpec.describe Subscription, type: :model do
  let(:today) { Date.current } # See https://github.com/braintree/braintree_ruby/issues/161

  describe '.display_names' do
    it 'is the human readable names for the various plans' do
      expect(described_class.display_names).to match_array ['Gym', 'Individual', 'League Gym', 'Participant']
    end
  end

  describe 'displayable traits' do
    let(:mock_gym_yearly_stripe_subscription) do
      build(:mock_stripe_subscription,
        plan_id: 'gym-yearly',
        price: 249.95)
    end
    let(:mock_league_gym_yearly_stripe_subscription) do
      build(:mock_stripe_subscription,
        plan_id: 'league-gym-yearly',
        price: 500.00) # ensure zero cents for test
    end
    let(:gym_yearly_subscription) do
      allow(Stripe::Subscription).to receive(:retrieve).and_return mock_gym_yearly_stripe_subscription

      create(:subscription, plan_category: 'SubscriptionPlan::Gym')
    end
    let(:league_gym_yearly_subscription) do
      allow(Stripe::Subscription).to receive(:retrieve).and_return mock_league_gym_yearly_stripe_subscription

      create(:subscription, plan_category: 'SubscriptionPlan::LeagueGym')
    end
    let(:braintreeless_subscription) do
      create(:subscription, plan_category: 'SubscriptionPlan::LeagueGym')
    end

    describe '#display_name' do
      # We do not distinguish between monthly and yearly plans in our domain
      # So we need to rely on the Braintree record in order to display a name
      # that conveys both the type and the charge cycle of the subscription
      # We are avoiding duplicating this information in our database
      # But also relying on Braintree's plan_id string to end with the cycle
      it 'is a human-readable phrase that describes their plan and its charge cycle' do
        expect(gym_yearly_subscription.display_name).to eq 'Gym Yearly'
      end

      it 'works for yearly plans with multiple-word names' do
        expect(league_gym_yearly_subscription.display_name).to eq 'League Gym Yearly'
      end

      it 'gracefully omits the charge cycle from Subscriptions without a braintree subscription' do # for example, ours on staging
        expect(braintreeless_subscription.display_name).to eq 'League Gym'
      end

      it 'logs the braintree find error and notifies Honeybadger' do
        expect(Rails.logger).to receive(:error)
        braintreeless_subscription.display_name
      end
    end

    describe '#description' do
      it 'is a human-readable phrase that includes price, charge cycle and contestant limits' do
        text = '$249.95 / year. 25 contestants per event.'
        expect(gym_yearly_subscription.description).to eq text
      end

      it 'is a human-readable phrase that includes price, charge cycle and contestant limits' do
        text = '$500.00 / year. Unlimited contestants per event.'
        expect(league_gym_yearly_subscription.description).to eq text
      end

      it 'gracefully omits the price from Subscriptions without a braintree subscription' do
        text = 'Unlimited contestants per event.'
        expect(braintreeless_subscription.description).to eq text
      end
    end

    describe '#display_payment_method' do
      it 'displays the last four digits of the credit card for the subscription' do
        token = mock_gym_yearly_stripe_subscription.default_source
        allow(Stripe::Customer).to receive(:retrieve_source)
          .with(mock_gym_yearly_stripe_subscription.customer, token)
          .and_return build(:mock_stripe_source)

        display_last4 = '**** **** **** 1111'
        expect(gym_yearly_subscription.display_payment_method).to eq display_last4
      end

      it 'is nil without a Stripe subscription' do
        expect(create(:subscription).display_payment_method).to be_nil
      end

      it 'is nil when there is a problem finding the payment method' do
        allow(Stripe::Customer).to receive(:retrieve_source)
          .and_raise Stripe::InvalidRequestError.new('method', 'param')

        expect(gym_yearly_subscription.display_payment_method).to be_nil
      end
    end
  end

  describe '#next_charge_amount' do
    let(:subscription) { build(:subscription) }
    let(:mock_stripe_subscription) do
      build(:mock_stripe_subscription, price: 10.00)
    end
    let(:upcoming_invoice) do
      build(:mock_stripe_invoice, amount_due: 1000) # in cents
    end
    let(:proration_preview) do
      build(:mock_stripe_invoice, total: -1000) # in cents
    end

    it 'is the price of their subscription, less any credit on file' do
      allow(Stripe::Subscription).to receive(:retrieve).and_return mock_stripe_subscription
      upcoming_invoice.amount_due = 700
      allow(Stripe::Invoice).to receive(:upcoming).and_return upcoming_invoice

      expect(subscription.next_charge_amount).to eq 7.00
    end

    it 'is never negative' do
      allow(Stripe::Subscription).to receive(:retrieve).and_return mock_stripe_subscription
      upcoming_invoice.amount_due = -200
      allow(Stripe::Invoice).to receive(:upcoming).and_return upcoming_invoice

      expect(subscription.next_charge_amount).to eq 0.00
    end

    it 'is nil when there is no Stripe subscription' do
      expect(subscription.next_charge_amount).to be_nil # $0 will send them a receipt, nil means it doesn't even try to bill them
    end

    it 'is nil when the subscription has been canceled' do
      allow(Stripe::Subscription).to receive(:retrieve).and_return mock_stripe_subscription
      subscription.update(status: 'Canceled')

      expect(subscription.next_charge_amount).to be_nil # $0 will send them a receipt, nil means it doesn't even try to bill them
    end
  end

  describe '#paid_up?' do
    it 'is false for accounts with no paid_through_date' do
      subscription = create(:subscription, paid_through_date: nil)
      expect(subscription.paid_up?).to be false
    end

    it 'is false for accounts paid through a date before today' do
      subscription = create(:subscription, paid_through_date: today - 1.day)
      expect(subscription.paid_up?).to be false
    end

    it 'is true for accounts paid through today (no matter what time it is or what time zone it is)', :time_zones, time_of_day: :hours do
      subscription = create(:subscription, paid_through_date: today)
      expect(subscription.paid_up?).to be true
    end

    it 'is true for accounts paid through a date after today' do
      subscription = create(:subscription, paid_through_date: today + 1.day)
      expect(subscription.paid_up?).to be true
    end

    it 'is true for subscriptions that are due to charge today' do
      subscription = create(:subscription, paid_through_date: today - 1.day, next_billing_date: today)
      expect(subscription.paid_up?).to be true
    end
  end

  describe '#cancel' do
    let(:subscription) do
      build(
        :subscription,
        paid_through_date: Date.current + 5.days,
        stripe_subscription_id: mock_stripe_subscription.id
      )
    end
    let(:mock_stripe_subscription) { build(:mock_stripe_subscription) }
    let(:failed_error_result) do
      Stripe::InvalidRequestError.new(
        'Stripe cancelation failed because reasons', nil
      )
    end

    before :each do
      allow(Stripe::Subscription).to receive(:retrieve).and_return mock_stripe_subscription
      allow(mock_stripe_subscription).to receive(:delete).with(no_args) do
        mock_stripe_subscription.status = 'canceled'
      end
    end

    it 'returns true when the Stripe subscription is already canceled' do
      mock_stripe_subscription.status = 'canceled'
      expect(subscription.cancel).to be true
      expect(subscription).to be_canceled
    end

    it 'cancels the Stripe subscription' do
      subscription.cancel
      expect(mock_stripe_subscription.status).to eq 'canceled'
    end

    it 'can cancel a subscription who has no Stripe subscription' do
      subscription.stripe_subscription_id = nil
      expect(subscription.cancel).to be true
      expect(subscription).to be_canceled
    end

    it 'does not update our subscription when Stripe cancelation fails' do
      allow(mock_stripe_subscription).to receive(:delete).and_raise failed_error_result
      expect(subscription).not_to receive(:update)
      expect(subscription).not_to receive(:save)
      expect { subscription.cancel }.to raise_error(Stripe::InvalidRequestError)
    end

    it 'sets the next_billing_date to nil' do
      subscription.cancel
      expect(subscription.next_billing_date).to be_nil
    end

    it 'changes the status to Canceled since it will never charge again' do
      subscription.cancel
      expect(subscription).to be_canceled
    end

    context 'upgrading' do
      it 'shortens the paid_through_date to today' do # they get credit instead
        subscription.upgrade
        expect(subscription.paid_through_date).to eq Date.current
      end

      it 'does not advance a paid_through_date in the past' do
        subscription.paid_through_date = Date.current - 5.days
        original_paid_through_date = subscription.paid_through_date

        subscription.upgrade
        expect(subscription.paid_through_date).to eq original_paid_through_date
      end

      it 'can cancel even when there is no existing paid_through_date' do
        subscription.paid_through_date = nil
        subscription.upgrade
        expect(subscription).to be_canceled
        expect(mock_stripe_subscription).not_to have_received(:delete)
      end
    end

    context 'downgrading' do
      it 'does not change the paid_through_date' do
        expect { subscription.cancel }.not_to change(subscription, :paid_through_date)
        expect(mock_stripe_subscription.status).to eq 'canceled'
      end
    end
  end

  describe '#plan_id' do
    let(:subscription) do
      build(:subscription, paid_through_date: today + 15.days)
    end
    let(:mock_stripe_subscription) do
      build(:mock_stripe_subscription, plan_id: 'individual-yearly')
    end

    it 'is the id of the plan in Stripe' do
      allow(Stripe::Subscription).to receive(:retrieve).and_return mock_stripe_subscription

      expect(subscription.plan_id).to eq 'individual-yearly'
    end

    it 'is nil for subscriptions without a braintree subscription' do
      expect(subscription.plan_id).to be_nil
    end
  end

  describe '#remaining_balance' do
    let(:pending_subscription) do
      build(:subscription, paid_through_date: nil, next_billing_date: Date.current)
    end
    let(:mock_pending_stripe_subscription) do
      build(:mock_stripe_subscription,
        current_period_start: nil,
        current_period_end: nil)
    end

    let(:subscription) do
      build(:subscription, paid_through_date: today + 15.days)
    end
    let(:mock_stripe_subscription) do
      build(:mock_stripe_subscription,
        current_period_start: bt_date(today - 14.days), # 30 days in subscription
        current_period_end: bt_date(today + 15.days),
        price: 49.95)
    end
    let(:proration_preview) do
      build(:mock_stripe_invoice, total: 0)
    end

    it 'can express the paid up time remaining in a prorated dollar amount' do
      allow(Stripe::Subscription).to receive(:retrieve).and_return mock_stripe_subscription
      proration_preview.total = -2497
      allow(Stripe::Invoice).to receive(:upcoming).and_return proration_preview

      expected_credit = 24.97 # 15 / 30 * 49.95 (we drop portions of pennies)
      expect(subscription.remaining_balance).to eq expected_credit
    end

    it 'returns no credit for delinquent subscriptions' do
      subscription.paid_through_date = today - 2.months
      allow(Stripe::Subscription).to receive(:retrieve).and_return mock_stripe_subscription
      expect(subscription.remaining_balance).to eq 0.00
    end

    it 'returns no credit for Pending subscriptions' do
      allow(Stripe::Subscription).to receive(:retrieve).and_return mock_pending_stripe_subscription

      expect(pending_subscription.remaining_balance).to eq 0.00
    end

    it 'returns no credit on the last day of the subscription' do
      allow(Stripe::Subscription).to receive(:retrieve).and_return mock_stripe_subscription
      allow(Stripe::Invoice).to receive(:upcoming).and_return proration_preview
      expect(subscription.remaining_balance).to eq 0.00
    end

    it 'returns no credit when there is no Stripe subscription' do
      expect(subscription.remaining_balance).to eq 0.00
    end
  end

  describe '#plan_category' do
    let(:subscription) { build :subscription }

    it 'allows valid rule sets' do
      subscription.plan_category = Subscription::PLAN_CATEGORIES.first
      expect(subscription).to be_valid
    end

    it 'does not allow invalid rule sets' do
      subscription.plan_category = 'FAKE'
      expect(subscription).to_not be_valid
    end
  end

  describe '#plan' do
    class SubscriptionPlan::Dummy < SubscriptionPlan
    end

    let(:subscription) { build :subscription }

    it 'returns an instance of meaningful SubscriptionPlan' do
      expect(subscription.plan).to be_kind_of(SubscriptionPlan)
    end

    it 'returns an instance of meaningful SubscriptionPlan if it is defined' do
      subscription.plan_category = 'SubscriptionPlan::Dummy'
      expect(subscription.plan).to be_kind_of(SubscriptionPlan)
    end

    it 'resets plan when plan_category is changed' do
      expect(subscription.plan).to be_kind_of(SubscriptionPlan)
      subscription.plan_category = 'SubscriptionPlan::Dummy'
      expect(subscription.plan).to be_kind_of(SubscriptionPlan::Dummy)
    end
  end

  describe '#potential_upgrades' do
    describe 'with an existing Participant subscription' do
      subject(:subscription) do
        create(:subscription, plan_category: 'SubscriptionPlan::Participant')
      end

      it 'considers all but Participant to be upgrades' do
        expect(subscription.potential_upgrades).to match_array(%w[individual gym league-gym])
      end
    end

    describe 'with an existing Individual subscription' do
      subject(:subscription) do
        create(:subscription, plan_category: 'SubscriptionPlan::Individual')
      end

      it 'considers an Gym or LeagueGym subscription to be upgrades' do
        expect(subscription.potential_upgrades).to match_array(%w[gym league-gym])
      end
    end

    describe 'with an existing Gym subscription' do
      subject(:subscription) do
        create(:subscription, plan_category: 'SubscriptionPlan::Gym')
      end

      it 'considers a LeagueGym subscription to be an upgrade' do
        expect(subscription.potential_upgrades).to match_array(%w[league-gym])
      end
    end

    describe 'with an existing LeagueGym subscription' do
      subject(:subscription) do
        create(:subscription, plan_category: 'SubscriptionPlan::LeagueGym')
      end

      it 'considers all changes to be a downgrade' do
        expect(subscription.potential_upgrades).to match_array([])
      end
    end
  end

  context 'plan specific' do
    describe 'Participant' do
      let(:subscription) { build(:subscription, plan_category: 'SubscriptionPlan::Participant') }

      it 'limits max contestants' do
        expect(subscription.max_contestants).to be(Subscription::NO_CONTESTANTS)
      end

      it 'does not allow any users to be invited' do
        expect(subscription.max_user_count).to be(Subscription::INDIVIDUAL_USERS)
      end

      it 'has the lowest upgrade value' do
        expect(subscription.upgrade_value).to eq SubscriptionPlan::UPGRADE_VALUES.lowest
      end

      it 'can not create virtual events' do
        expect(subscription.virtual_events?).to be false
      end

      it 'does not create events' do
        expect(subscription.manage_events?).to be false
      end

      it 'has no initial credits' do
        expect(subscription.initial_credits).to eq 0
      end
    end

    describe 'Individual' do
      let(:subscription) { build(:subscription, plan_category: 'SubscriptionPlan::Individual') }

      it 'limits max contestants' do
        expect(subscription.max_contestants).to be(Subscription::VERY_LIMITED_CONTESTANTS)
      end

      it 'does not allow any users to be invited' do
        expect(subscription.max_user_count).to be(Subscription::INDIVIDUAL_USERS)
      end

      it 'has a low upgrade value' do
        expect(subscription.upgrade_value).to eq SubscriptionPlan::UPGRADE_VALUES.low
      end

      it 'can not create virtual events' do
        expect(subscription.virtual_events?).to be false
      end

      it 'create events' do
        expect(subscription.manage_events?).to be true
      end

      it 'has no initial credits' do
        expect(subscription.initial_credits).to eq 0
      end
    end

    describe 'Gym' do
      let(:subscription) { build(:subscription, plan_category: 'SubscriptionPlan::Gym') }

      it 'limits max contestants' do
        expect(subscription.max_contestants).to be(Subscription::LIMITED_CONTESTANTS)
      end

      it 'allows a limited number of users to be invited' do
        expect(subscription.max_user_count).to be(Subscription::GYM_USERS)
      end

      it 'has a medium upgrade value' do
        expect(subscription.upgrade_value).to eq SubscriptionPlan::UPGRADE_VALUES.medium
      end

      it 'creates virtual events' do
        expect(subscription.virtual_events?).to be true
      end

      it 'create events' do
        expect(subscription.manage_events?).to be true
      end

      it 'has 10 initial credits' do
        expect(subscription.initial_credits).to eq 10
      end
    end

    describe 'League Gym' do
      let(:subscription) { build(:subscription, plan_category: 'SubscriptionPlan::LeagueGym') }

      it 'has unlimited max contestants' do
        expect(subscription.max_contestants).to be(Subscription::UNLIMITED_CONTESTANTS)
      end

      it 'allows a limited number of users to be invited' do
        expect(subscription.max_user_count).to be(Subscription::LEAGUE_GYM_USERS)
      end

      it 'has a high upgrade value' do
        expect(subscription.upgrade_value).to eq SubscriptionPlan::UPGRADE_VALUES.high
      end

      it 'creates virtual events' do
        expect(subscription.virtual_events?).to be true
      end

      it 'create events' do
        expect(subscription.manage_events?).to be true
      end

      it 'has 20 initial credits' do
        expect(subscription.initial_credits).to eq 20
      end
    end
  end
end
