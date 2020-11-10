require 'rails_helper'

RSpec.describe Organization do
  # Organization and users
  let(:organization) { create(:organization) }
  let(:org_admin) do
    create(:user, :org_admin, organization: organization)
  end
  let(:support_admin) do
    create(:user, :support_admin, organization: organization)
  end

  # Subscriptions
  let(:active_subscription) { create(:subscription, organization: organization) }
  let(:upcoming_subscription) do
    create(
      :subscription,
      organization: organization,
      status: 'Pending',
      paid_through_date: nil,
      next_billing_date: Date.current + 10.days
    )
  end

  describe 'validations' do
    it 'ensures that the name is present' do
      expect(organization).to be_valid
      organization.name = ''
      expect(organization).not_to be_valid
    end

    it 'ensures that the credits are greater than or equal to 0' do
      expect(organization).to be_valid
      organization.credits = -2
      expect(organization).not_to be_valid
      organization.credits = 6
      expect(organization).to be_valid
      organization.credits = 0
      expect(organization).to be_valid
    end
  end

  describe '#max_contestants' do
    it 'returns default when no subscription' do
      expect(organization.max_contestants).to be Subscription::NO_CONTESTANTS
    end

    it 'returns whatever its subscription returns' do
      active_subscription
      expect(organization.max_contestants).to be active_subscription.max_contestants
    end
  end

  describe '#has_credits?' do
    it 'is true when credits remain' do
      organization.credits = 3
      expect(organization.has_credits?).to eq(true)
    end

    it 'is false when no credits are left' do
      organization.credits = 0
      expect(organization.has_credits?).to eq(false)
    end
  end

  describe '#spend_credit' do
    context 'when the organization has credits' do
      before :each do
        organization.credits = 2
      end

      it 'reduces the credit count by 1 when there are credits' do
        organization.spend_credit
        expect(organization.credits).to eq 1
      end

      it 'reduces the credit count by a given number when there are enough credits' do
        organization.spend_credit(2)
        expect(organization.credits).to eq 0
      end

      it 'will not overspend' do
        organization.spend_credit(3)
        expect(organization.credits).to eq 2
      end
    end

    context 'when the organization is out of credits' do
      it 'keeps the credit count at 0' do
        organization.spend_credit
        expect(organization.credits).to eq 0
      end
    end
  end

  describe '#add_credit' do
    let(:organization) { build(:organization) }

    context 'first subscription' do
      let(:new_subscription) do
        build(:subscription, organization: organization, plan_category: 'SubscriptionPlan::LeagueGym')
      end

      it 'adds the total new subscription credits to its credits' do
        expect {
          organization.add_credits(new_subscription)
        }.to change(organization, :credits).by(new_subscription.initial_credits)
      end
    end

    context 'upgraded subscription' do
      let(:new_subscription) do
        build(:subscription, organization: organization, plan_category: 'SubscriptionPlan::LeagueGym')
      end
      let(:old_subscription) do
        build(:subscription, organization: organization, plan_category: 'SubscriptionPlan::Gym')
      end

      before :each do
        organization.subscriptions << old_subscription
        organization.spend_credit
      end

      it 'adds the increase in new subscription credits to its credits' do
        expect {
          organization.add_credits(new_subscription)
        }.to change(organization, :credits).by(new_subscription.initial_credits - old_subscription.initial_credits)
      end
    end

    context 'changed to new subscription of same plan value' do
      let(:new_subscription) do
        build(:subscription, organization: organization, plan_category: 'SubscriptionPlan::LeagueGym')
      end
      let(:old_subscription) do
        build(:subscription, organization: organization, plan_category: 'SubscriptionPlan::LeagueGym')
      end

      before :each do
        organization.subscriptions << old_subscription
        organization.spend_credit
      end

      it 'does not change the number of credits' do
        expect {
          organization.add_credits(new_subscription)
        }.not_to change(organization, :credits)
      end
    end

    context 'downgraded subscription' do
      let(:new_subscription) do
        build(:subscription, organization: organization, plan_category: 'SubscriptionPlan::Gym')
      end
      let(:old_subscription) do
        build(:subscription, organization: organization, plan_category: 'SubscriptionPlan::LeagueGym')
      end

      before :each do
        organization.subscriptions << old_subscription
      end

      it 'does not change the number of credits' do
        expect {
          organization.add_credits(new_subscription)
        }.not_to change(organization, :credits)
      end
    end
  end

  describe '#max_user_count' do
    it 'returns default when no subscription' do
      expect(organization.max_user_count).to be Subscription::PARTICIPANT_USERS
    end

    it 'returns whatever its subscription returns' do
      active_subscription
      expect(organization.max_user_count).to be active_subscription.max_user_count
    end
  end

  describe '#active_subscription' do
    let(:invited_subscription) do
      create(:subscription, organization: organization, status: 'Invited')
    end

    let(:active_trialing) do
      create(:subscription,
        organization: organization,
        status: 'Trialing',
        paid_through_date: 3.days.from_now,
        next_billing_date: 2.days.from_now)
    end
    let(:active_but_expired) do
      create(:subscription,
        organization: organization,
        status: 'Active',
        paid_through_date: 3.days.ago,
        next_billing_date: 2.days.ago)
    end
    let(:canceled_and_paid_up) do
      create(:subscription,
        organization: organization,
        status: 'Canceled',
        paid_through_date: Date.current + 10.days,
        next_billing_date: nil
      )
    end
    let(:canceled_and_paid_up_again) do
      create(:subscription,
        organization: organization,
        status: 'Canceled',
        paid_through_date: Date.current + 10.days,
        next_billing_date: nil
      )
    end
    let(:pending_and_starting) do
      create(:subscription,
        organization: organization,
        status: 'Pending',
        paid_through_date: nil,
        next_billing_date: Date.current
      )
    end

    # the subscription which is their basis for access at this point in time
    it 'returns the default subscription when they have no subscriptions' do
      expect(organization.active_subscription.attributes).to eq Subscription.default.attributes
    end

    it 'returns the first active subscription it finds' do
      active_subscription
      expect(organization.active_subscription).to eql active_subscription
    end

    it 'returns a trialing active subscription' do
      active_trialing
      expect(organization.active_subscription).to eql active_trialing
    end

    it 'ignores an expired but "active" subscription' do
      active_but_expired
      expect(organization.active_subscription).not_to eq active_but_expired
    end

    it 'returns the first invited subscription it finds' do
      invited_subscription
      expect(organization.active_subscription).to eql invited_subscription
    end

    it 'returns a canceled subscripion that is winding down' do
      canceled_and_paid_up
      expect(organization.active_subscription).to eql canceled_and_paid_up
    end

    it 'chooses the most recent canceled subscription when the user has changed their subscription more than once today' do
      canceled_and_paid_up
      canceled_and_paid_up_again
      expect(organization.active_subscription).to eql canceled_and_paid_up_again
    end

    it 'returns a pending subscription which is starting up' do
      pending_and_starting
      expect(organization.active_subscription).to eql pending_and_starting
    end

    it 'ignores expired canceled subscriptions and future pending subscriptions' do
      canceled_and_paid_up.update(paid_through_date: Date.current - 10.days)
      pending_and_starting.update(next_billing_date: Date.current + 10.days)
      expect(organization.active_subscription.attributes).to eq Subscription.default.attributes
    end
  end

  describe '#upcoming_subscription' do
    it 'returns nil when there are no pending subscriptions' do
      expect(organization.upcoming_subscription).to eql nil
    end

    it 'returns the first subscription it finds which has not billed yet' do
      active_subscription
      upcoming_subscription
      expect(organization.upcoming_subscription).to eql upcoming_subscription
    end
  end

  describe '#upgrading?, #potential_upgrades' do
    describe 'with an existing Participant subscription' do
      let!(:subscription) do
        create(
          :subscription,
          organization: organization,
          plan_category: 'SubscriptionPlan::Participant'
        )
      end

      it 'considers all but Participant to be upgrades' do
        expect(organization.upgrading?('SubscriptionPlan::Participant')).to be false
        expect(organization.upgrading?('SubscriptionPlan::Individual')).to be true
        expect(organization.upgrading?('SubscriptionPlan::Gym')).to be true
        expect(organization.upgrading?('SubscriptionPlan::LeagueGym')).to be true
        expect(organization.active_subscription.potential_upgrades).to match_array(%w[individual gym league-gym])
      end
    end

    describe 'with an existing Individual subscription' do
      let!(:subscription) do
        create(
          :subscription,
          organization: organization,
          plan_category: 'SubscriptionPlan::Individual'
        )
      end

      it 'considers a Participant or Individual subscription to be a downgrade' do
        expect(organization.upgrading?('SubscriptionPlan::Participant')).to be false
        expect(organization.upgrading?('SubscriptionPlan::Individual')).to be false
      end

      it 'considers an Gym or LeagueGym subscription to be upgrades' do
        expect(organization.upgrading?('SubscriptionPlan::Gym')).to be true
        expect(organization.upgrading?('SubscriptionPlan::LeagueGym')).to be true
        expect(organization.active_subscription.potential_upgrades).to match_array(%w[gym league-gym])
      end
    end

    describe 'with an existing Gym subscription' do
      let!(:subscription) do
        create(
          :subscription,
          organization: organization,
          plan_category: 'SubscriptionPlan::Gym'
        )
      end

      it 'considers a Participant, Individual, or Gym subscription to be a downgrade' do
        expect(organization.upgrading?('SubscriptionPlan::Participant')).to be false
        expect(organization.upgrading?('SubscriptionPlan::Individual')).to be false
        expect(organization.upgrading?('SubscriptionPlan::Gym')).to be false
      end

      it 'considers a LeagueGym subscription to be an upgrade' do
        expect(organization.upgrading?('SubscriptionPlan::LeagueGym')).to be true
        expect(organization.active_subscription.potential_upgrades).to match_array(['league-gym'])
      end
    end

    describe 'with an existing LeagueGym subscription' do
      let!(:subscription) do
        create(
          :subscription,
          organization: organization,
          plan_category: 'SubscriptionPlan::LeagueGym'
        )
      end

      it 'considers all changes to be a downgrade' do
        expect(organization.upgrading?('SubscriptionPlan::Participant')).to be false
        expect(organization.upgrading?('SubscriptionPlan::Individual')).to be false
        expect(organization.upgrading?('SubscriptionPlan::Gym')).to be false
        expect(organization.upgrading?('SubscriptionPlan::LeagueGym')).to be false
        expect(organization.active_subscription.potential_upgrades).to match_array([])
      end
    end
  end

  describe '#admin_email' do
    it 'returns the email address of the first org admin' do
      org_admin
      expect(organization.admin_email).to eq org_admin.email
    end

    it 'returns the email address of the first support user' do
      support_admin
      expect(organization.admin_email).to eq support_admin.email
    end

    it 'returns nil without admins' do
      expect(organization.admin_email).to be nil
    end
  end

  describe '#plan_category' do
    it 'returns the type of the active subscription' do
      active_subscription
      expect(organization.plan_category).to eq("Gym")
    end

    it 'returns the default when the user does not have a paid subscription' do
      expect(organization.plan_category).to eq Subscription.default.plan_category.sub('SubscriptionPlan::', '')
    end
  end

  describe '#status' do
    it 'returns \'Active\' when there is just one active subscription' do
      active_subscription
      expect(organization.status).to eq 'active'
    end

    it 'returns \'Canceled\' when all the subscriptions are canceled' do
      active_subscription.cancel
      expect(organization.status).to eq 'canceled'
    end

    it 'returns \'Downgrading\' when the user has an upcoming subscription' do
      active_subscription.cancel
      upcoming_subscription
      expect(organization.status).to eq 'Downgrading'
    end

    it 'returns nil when there is no subscription' do
      expect(organization.status).to eq nil
    end
  end

  describe '#paid_through_date' do
    it 'returns the active subscription paid_through_date' do
      active_subscription
      expect(organization.paid_through_date).to eq active_subscription.paid_through_date
    end

    it 'returns nil when there is no active subscription' do
      expect(organization.paid_through_date).to be nil
    end
  end

  describe '#next_billing_date' do
    it 'returns the next date braintree will bill the customer on the active subscription' do
      active_subscription
      expect(organization.paid_through_date).to eq active_subscription.paid_through_date
    end

    it 'returns nil when there is no active subscription' do
      expect(organization.next_billing_date).to be nil
    end
  end
end
