# frozen_string_literal: true

class SubscriptionPlan
  delegate :max_contestants, :max_user_count, :manage_events?,
    :virtual_events?, :upgrade_value, :multiple_courses?, :waves?, :initial_credits,
    :registration?, :view_leader_boards?, :associate_athletes?, to: :class

  UPGRADE_VALUES = OpenStruct.new(
    bottom: 0,
    lowest: 1,
    low: 2,
    medium: 3,
    high: 4
  )

  # Discount amounts (not price after discount!) for each plan level affected
  # by a promotion code, along with its expiration date. If no expiration is
  # set, promotion will be active!
  #
  # NOTE: Promo codes should always be UPPERCASED so that we can compare without
  #   case sensitivity!
  ACTIVE_PROMOTIONS = {
    'UNAA' => {
      'expires_on' => Date.parse('2025-08-01'),
      'league-gym-yearly' => 100.00
    }
  }.freeze

  class << self
    def max_contestants
      Subscription::UNLIMITED_CONTESTANTS
    end

    def max_user_count
      Subscription::LEAGUE_GYM_USERS
    end

    def manage_events?
      true
    end

    def virtual_events?
      false
    end

    def upgrade_value
      UPGRADE_VALUES.high
    end

    def multiple_courses?
      false
    end

    def waves?
      true
    end

    def registration?
      true
    end

    def initial_credits
      0
    end

    def view_leader_boards?
      true
    end

    def associate_athletes?
      false
    end

    # Descendants here means subclasses of SubscriptionPlan; we ask each type
    # of SubscriptionPlan for its available_plans.
    def available_plans
      @available_plans ||= descendants.sort_by(&:upgrade_value).flat_map do |descendant|
        descendant.available_plans.sort_by { |plan| plan[:price] }
      end
    end

    def available_plan_ids
      available_plans.map { |plan_detail| plan_detail[:planId] }
    end

    # Return promotions for promo code.
    # If none exist or promotion is expired, return empty hash.
    def active_promotions(promotion_code:)
      ACTIVE_PROMOTIONS.fetch(promotion_code&.upcase, {}).tap do |promotion|
        return {} if promotion.fetch('expires_on', Date.current) < Date.current
      end
    end
  end
end

# Ensure Rails loads the descendants, used for 'available_plans' determination.
# (Only affects development mode; other modes cache classes sufficiently.)
Dir[Rails.root.join('app', 'models', 'subscription_plan', '*.rb')].each do |file|
  require_dependency file
end
