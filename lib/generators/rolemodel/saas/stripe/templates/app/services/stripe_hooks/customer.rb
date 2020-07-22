# frozen_string_literal: true

module StripeHooks
  class Customer < Base
    def process
      return unless subscription_event?

      paid_through_date = Time.zone.at(subscription.current_period_end) + Subscription::GRACE_PERIOD
      Subscription.find_by(stripe_subscription_id: subscription.id)
        &.update(
          paid_through_date: paid_through_date,
          next_billing_date: 1.day.after(paid_through_date),
          status: subscription.status
        )
    end

    private

    def subscription
      event.data.object
    end

    def subscription_event?
      event.type.include?('subscription')
    end
  end
end
