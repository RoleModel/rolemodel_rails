# frozen_string_literal: true

class SubscriptionPlan::Registration < SubscriptionPlan
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
      SubscriptionPlan::UPGRADE_VALUES.bottom
    end

    def waves?
      false
    end

    def registration?
      false
    end

    def view_leader_boards?
      false
    end

    # NOTE: If we ever add plans which need to be in Stripe, run `rails stripe:create_subscriptions`
    def available_plans
      []
    end
  end
end
