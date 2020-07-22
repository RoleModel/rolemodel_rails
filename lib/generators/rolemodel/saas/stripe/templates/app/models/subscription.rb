# frozen_string_literal: true

class Subscription < ApplicationRecord
  PLAN_CATEGORIES = [
    SubscriptionPlan::Participant,
    SubscriptionPlan::Individual,
    SubscriptionPlan::Gym,
    SubscriptionPlan::LeagueGym
  ].map(&:name)
  UNLIMITED_CONTESTANTS = 100000 # More than reasonable for now
  LIMITED_CONTESTANTS = 25
  VERY_LIMITED_CONTESTANTS = 5
  NO_CONTESTANTS = 0
  LEAGUE_GYM_USERS = 5
  GYM_USERS = 3
  INDIVIDUAL_USERS = 1
  PARTICIPANT_USERS = 1

  # Grace period to allow card to go through and Stripe to notify our webhooks
  GRACE_PERIOD = 1.day

  has_many :subscription_descriptions
  belongs_to :organization, inverse_of: :subscriptions
  validates :plan_category, inclusion: { in: PLAN_CATEGORIES }
  accepts_nested_attributes_for :subscription_descriptions

  delegate :manage_events?, :virtual_events?, :waves?, :max_contestants,
    :max_user_count, :upgrade_value, :initial_credits, :registration?,
    :view_leader_boards?, :associate_athletes?, :multiple_courses?, to: :plan

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
    [
      display_price,
      "#{display_contestants} contestants per event."
    ].compact.join(' ')
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
    minimum_league_gym_days = 62

    # Makes sure they are on a league gym monthly plan, and they are not trying to upgrade
    return false if target_plan == 'league-gym-yearly'

    paid_for_three_months = (paid_through_date.to_time - created_at).to_i / 1.day < minimum_league_gym_days

    plan_category == 'SubscriptionPlan::LeagueGym' &&
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

  def display_contestants
    max_contestants == UNLIMITED_CONTESTANTS ? 'Unlimited' : max_contestants
  end

  # TODO: Simplify in TR#1248
  def gateway_subscription
    @gateway_subscription ||=
      if braintree_subscription_id?
        Subscription::Braintree.new(braintree_subscription_id)
      else
        Subscription::Stripe.new(stripe_subscription_id)
      end
  rescue ::Braintree::NotFoundError, ::Stripe::InvalidRequestError
    @gateway_subscription = Subscription::Null.new
  end

  def delinquent
    !paid_through_date || paid_through_date < Date.current
  end
end
