# frozen_string_literal: true

class SubscriptionPlan::Organization < SubscriptionPlan
  class << self
    def max_user_count
      Subscription::ORGANIZATION_USERS
    end

    def upgrade_value
      SubscriptionPlan::UPGRADE_VALUES.medium
    end

    def initial_credits
      10
    end

    # NOTE: If these plans change, you likely need to run `rails stripe:create_subscriptions`
    def available_plans
      [
        {
          planId: 'organization-yearly',
          label: 'Organization Yearly',
          price: 299.95,
          duration: 'year',
          frequency: 'Yearly'
        },
        {
          planId: 'organization-monthly',
          label: 'Organization Monthly',
          price: 29.99,
          duration: 'month',
          frequency: 'Monthly'
        }
      ]
    end
  end
end
