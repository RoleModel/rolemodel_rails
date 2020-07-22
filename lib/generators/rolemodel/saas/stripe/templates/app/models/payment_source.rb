# frozen_string_literal: true

class PaymentSource
  attr_reader :payment_token, :user

  def initialize(user, payment_token)
    @payment_token = payment_token
    @user = user
  end

  # Customer ID in Gym if connect_account, otherwise Customer ID in NinjaMaster
  def connected_customer_id(account_id)
    user.verified_stripe_customer_id(account_id)
  end

  # Customer ID in NinjaMaster
  def stripe_customer_id
    @stripe_customer_id ||= user.verified_stripe_customer_id
  end

  def connected_account(order)
    org = order.event ? order.event.organization : order.season&.league&.organization
    org&.stripe_connect_account
  end

  def connected_account_id(order)
    connected_account(order)&.id
  end

  def source(account_id = nil)
    return card if account_id.blank?

    token = Stripe::Source.create({
      customer: stripe_customer_id,
      original_source: card
    }, stripe_account: account_id)
    # associate to the gym's copy of the customer
    Stripe::Customer.create_source(
      connected_customer_id(account_id),
      { source: token },
      stripe_account: account_id
    )
  end

  private

  def card
    # associate that card we just got with the customer
    @card ||= Stripe::Customer.create_source(
      stripe_customer_id,
      source: payment_token
    )
  end
end
