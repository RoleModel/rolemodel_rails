# frozen_string_literal: true

# Serves as a "join table" between the payment gateway (Stripe) and our Users
# Entries with a null `connect_account` field are customer ids in the NM Stripe
# account, while others are customer records in gym Stripe Connect accounts.
class UserGatewayId < ApplicationRecord
  belongs_to :user

  validates :connect_account, uniqueness: { scope: :user }

  def verified_stripe_customer_id
    begin
      customer = Stripe::Customer.retrieve(stripe_customer_id, stripe_account: connect_account)
      create_stripe_customer if customer.deleted?
    rescue Stripe::StripeError
      create_stripe_customer
    end
    stripe_customer_id
  end

  private

  def create_stripe_customer
    customer =
      Stripe::Customer.list({ email: user.email }, stripe_account: connect_account).first ||
      Stripe::Customer.create({
        email: user.email,
        name: user.name,
        metadata: { application_user_id: user.id }
      }, stripe_account: connect_account)
    update(stripe_customer_id: customer.id)
  end
end
