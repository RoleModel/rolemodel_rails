# frozen_string_literal: true

class Subscription
  class Stripe
    attr_reader :subscription

    def initialize(subscription_id)
      @subscription = ::Stripe::Subscription.retrieve(subscription_id)
    rescue ::Stripe::InvalidRequestError
      Rails.logger.error "Could not retrieve Stripe subscription #{subscription_id}"
      raise
    end

    def plan_id
      subscription.plan.id
    end

    def price
      subscription.plan.amount.to_d / 100
    end

    def display_charge_cycle
      subscription.plan.interval + 'ly'
    end

    def display_price
      "$#{format('%.2f', price)} / #{subscription.plan.interval}."
    end

    def display_payment_method
      return nil unless subscription.default_source

      payment_source =
        ::Stripe::Customer.retrieve_source(subscription.customer, subscription.default_source)
      "**** **** **** #{payment_source.last4}"
    rescue ::Stripe::InvalidRequestError
      Rails.logger.error "Could not retrieve Stripe payment method #{subscription.default_source}"
      nil
    end

    def next_charge_amount
      amount = next_invoice&.amount_due.to_d / 100
      amount.negative? ? 0 : amount
    end

    # Provide a preview of proration credit by pretending to cancel immediately.
    # Stripe provides the actual credit as a negative, but we "want" this as a
    # positive, so flip the negative...
    def remaining_balance
      proration_preview = ::Stripe::Invoice.upcoming(
        subscription: subscription.id,
        subscription_cancel_at: Date.current.end_of_day.to_i
      )
      -proration_preview.total.to_d / 100
    rescue ::Stripe::InvalidRequestError
      0
    end

    def cancel!
      subscription.delete unless subscription.status == 'canceled'
    end

    def upgrade!; end

    private

    def next_invoice
      @next_invoice ||= ::Stripe::Invoice.upcoming(subscription: subscription.id)
    rescue ::Stripe::InvalidRequestError
      nil # Subscription was probably canceled and therefore cannot be upcoming
    end
  end
end
