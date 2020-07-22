# frozen_string_literal: true

class Subscription < ApplicationRecord
  PLAN_CATEGORIES = [
    SubscriptionPlan::Participant,
    SubscriptionPlan::Individual,
    SubscriptionPlan::Organization
  ].map(&:name)
  INDIVIDUAL_USERS = 1
  PARTICIPANT_USERS = 1
  ORGANIZATION_USERS = 5

  # Grace period to allow card to go through and Stripe to notify our webhooks
  GRACE_PERIOD = 1.day

  has_many :subscription_descriptions
  belongs_to :organization, inverse_of: :subscriptions
  validates :plan_category, inclusion: { in: PLAN_CATEGORIES }
  accepts_nested_attributes_for :subscription_descriptions

  delegate :max_user_count, :upgrade_value, :initial_credits, :registration?, to: :plan

  delegate :display_charge_cycle, :plan_id, :price, :display_price,
    :display_payment_method, to: :gateway_subscription

  enum status: {
    active: 'Active', canceled: 'Canceled', pending: 'Pending', invited: 'Invited',
    inactive: 'Inactive', incomplete: 'Incomplete', trialing: 'Trialing',
    incomplete_expired: 'incomplete_expired', past_due: 'past_due', unpaid: 'unpaid'
  }

  def self.default
    new(plan_category: 'SubscriptionPlan::Registration')
  end

  def self.build_from(organization, plan_category, stripe_subscription, mark_pending: false)
    paid_through_date = Time.zone.at(stripe_subscription.current_period_end)
    new(
      organization: organization,
      stripe_subscription_id: stripe_subscription.id,
      paid_through_date: mark_pending ? nil : paid_through_date,
      next_billing_date: paid_through_date,
      plan_category: plan_category,
      status: mark_pending ? :pending : stripe_subscription.status
    )
  end

  def potential_upgrades
    PLAN_CATEGORIES.each_with_object([]) do |category_string, collection|
      prefix = category_string.demodulize.underscore.dasherize
      collection << prefix if category_string.constantize.upgrade_value > plan_category.constantize.upgrade_value
    end
  end

  def self.display_names
    PLAN_CATEGORIES.map { |plan_category| plan_category.demodulize.titlecase }
  end

  def display_name
    text = plan_category.demodulize
    text += " #{display_charge_cycle}" if display_charge_cycle
    text.titlecase # e.g. 'Individual Yearly'
  end

  def description
    display_price
  end

  def plan_category=(plan_category_string)
    @plan = nil
    super(plan_category_string)
  end

  def plan
    @plan ||= plan_category.constantize.new
  end

  def paid_up?
    !delinquent || next_billing_date == Date.current
  end

  def next_charge_amount
    return nil if canceled?

    gateway_subscription.next_charge_amount
  end

  def remaining_balance
    return 0 if !paid_up? || delinquent

    gateway_subscription.remaining_balance
  end

  def cancel
    return true if canceled?

    gateway_subscription.cancel!
    cancel_locally!
  end

  def upgrade
    return true if canceled?

    gateway_subscription.upgrade!
    cancel_locally!(true)
  end

  def cancel_locally!(upgrading = false)
    return true if canceled?

    date = upgrading ? [paid_through_date, Date.current].compact.min : paid_through_date
    update(paid_through_date: date, next_billing_date: nil, status: 'Canceled')
  end

  def downgrade_not_available?(target_plan:)
    minimum_days = 62

    # Makes sure they are on a organization monthly plan, and they are not trying to upgrade
    return false if target_plan == 'organization-yearly'

    paid_for_three_months = (paid_through_date.to_time - created_at).to_i / 1.day < minimum_days

    plan_category == 'SubscriptionPlan::Organization' &&
      display_charge_cycle == 'monthly' && paid_for_three_months
  end

  def reload
    @gateway_subscription = nil
    super
  end

  def as_json(*)
    super.merge(
      plan_id: plan_id,
      next_billing_date: next_billing_date.try(:strftime, '%B %e, %Y'),
      remaining_balance: remaining_balance.to_f,
      potential_upgrades: potential_upgrades
    )
  end

  private

  def gateway_subscription
    @gateway_subscription ||= Subscription::Stripe.new(stripe_subscription_id)
  rescue ::Stripe::InvalidRequestError
    @gateway_subscription = Subscription::Null.new
  end

  def delinquent
    !paid_through_date || paid_through_date < Date.current
  end
end
