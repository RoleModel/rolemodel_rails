# frozen_string_literal: true

class SubscriptionPlan::Participant < SubscriptionPlan
  class << self
    def max_contestants
      Subscription::NO_CONTESTANTS
    end

    def max_user_count
      Subscription::PARTICIPANT_USERS
    end

    def manage_events?
      false
    end

    def upgrade_value
      SubscriptionPlan::UPGRADE_VALUES.lowest
    end

    def waves?
      false
    end

    def registration?
      false
    end

    # NOTE: If these plans change, you likely need to run `rails stripe:create_subscriptions`
    def available_plans
      [
        {
          planId: 'participant-yearly',
          label: 'Participant Yearly',
          price: 24.95,
          duration: 'year',
          frequency: 'Yearly',
          extra_description: 'View all virtual events and leaderboards.'
        },
        {
          planId: 'participant-monthly',
          label: 'Participant Monthly',
          price: 2.49,
          duration: 'month',
          frequency: 'Monthly',
          extra_description: 'View all virtual events and leaderboards.'
        }
      ]
    end
  end
end
