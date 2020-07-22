# frozen_string_literal: true

class SubscriptionPlan::Individual < SubscriptionPlan
  class << self
    def max_user_count
      Subscription::INDIVIDUAL_USERS
    end

    def upgrade_value
      SubscriptionPlan::UPGRADE_VALUES.low
    end

    def registration?
      false
    end

    # NOTE: If these plans change, you likely need to run `rails stripe:create_subscriptions`
    def available_plans
      [
        {
          planId: 'individual-yearly',
          label: 'Individual Yearly',
          price: 59.95,
          duration: 'year',
          frequency: 'Yearly'
        },
        {
          planId: 'individual-monthly',
          label: 'Individual Monthly',
          price: 5.99,
          duration: 'month',
          frequency: 'Monthly'
        }
      ]
    end
  end
end
