# frozen_string_literal: true

class SubscriptionsController < AuthenticationController
  layout 'subscription'

  helper_method :current_subscription

  # This is actually here because the `redirect if existing_subscription?` does
  # not authorize anything first... Fix it later.
  skip_after_action :verify_authorized

  before_action :set_subscription_options, only: %i[new edit]
  before_action :verify_plan_selected, only: %i[create update]

  rescue_from Stripe::StripeError, with: :subscription_failure

  def new
    return redirect_to edit_subscription_path if existing_subscription?

    @plan_id = plan_id_params if SubscriptionPlan.available_plan_ids.include?(plan_id_params)
  end

  def create
    return update if existing_subscription?

    stripe_subscription = create_or_update_stripe_subscription
    save_subscription(stripe_subscription)

    redirect_to after_subscription_url, notice: I18n.t('subscriptions.notices.payment_successful')
  end

  def edit
    return redirect_to new_subscription_path unless existing_subscription?

    @plan_id = current_subscription.plan_id
    @discontinued_plan = @plan_options.none? { |plan| plan[:planId] == @plan_id }
  end

  def update
    return create unless existing_subscription?

    if current_subscription.downgrade_not_available?(target_plan: plan_id_params)
      return redirect_to organization_path, notice: I18n.t('subscriptions.notices.unavailable_downgrade')
    end

    stripe_subscription = create_or_update_stripe_subscription
    reconcile_local_subscriptions!

    save_subscription(stripe_subscription)

    redirect_to organization_path, notice: I18n.t('subscriptions.notices.update_successful')
  end

  def cancel
    already_canceled = current_organization.subscriptions.all?(&:canceled?)
    return redirect_to organization_path, notice: I18n.t('subscriptions.notices.already_canceled') if already_canceled

    if current_subscription.downgrade_not_available?(target_plan: plan_id_params)
      return redirect_to organization_path, notice: I18n.t('subscriptions.notices.unavailable_cancellation')
    end

    message = if cancel_all_subscriptions
                I18n.t('subscriptions.notices.cancelation_successful')
              else
                I18n.t('subscriptions.errors.update_failed')
              end
    redirect_to organization_path, notice: message
  end

  # @note api request which only serves JSON
  def promotions
    render json: SubscriptionPlan.active_promotions(promotion_code: promotion_code)
  end

  private

  def set_subscription_options
    @plan_options = SubscriptionPlan.available_plans
  end

  def verify_plan_selected
    return if plan_id_params.present?

    redirect_back(
      fallback_location: existing_subscription? ? edit_subscription_path : new_subscription_path,
      notice: I18n.t('subscriptions.notices.must_select_plan')
    )
  end

  def subscription_failure(exception)
    redirect_to(
      existing_subscription? ? edit_subscription_path : new_subscription_path,
      notice: exception.message || I18n.t('subscriptions.errors.payment_failed')
    )
  end

  def upgrading?
    current_organization.upgrading?(plan_category) if plan_category
  end

  def existing_subscription?
    current_organization.active_subscription.plan_category != Subscription.default.plan_category
  end

  def current_subscription
    @current_subscription ||= begin
      subscription = existing_subscription? ? current_organization.active_subscription : nil
      authorize subscription || Subscription.new(organization: current_organization)
    end
  end

  def perform_stripe_update?
    (current_subscription.stripe_subscription_id? && current_subscription.active?) ||
      current_organization.upcoming_subscription.present?
  end

  # Check if user has an existing subscription ... and that it's active in Stripe.
  # If so, update the Stripe subscription ...
  # Otherwise, create a new subscription. This may happen if the old subscription
  #   was in Braintree; this method only needs to create the new one, the old
  #   will get canceled elsewhere.
  def create_or_update_stripe_subscription
    if perform_stripe_update?
      Stripe::Subscription.update(
        existing_stripe_subscription.id,
        items: [{ id: existing_stripe_subscription.items.first.id, plan: plan_id_params }],
        default_source: payment_source,
        coupon: validated_promotion_code,
        billing_cycle_anchor: upgrading? ? 'now' : nil,
        prorate: upgrading?
      )
    else
      apply_remaining_balance_from_current_subscription! if existing_subscription?
      Stripe::Subscription.create(
        customer: current_organization.verified_stripe_customer_id,
        items: [{ plan: plan_id_params }],
        default_source: payment_source,
        coupon: validated_promotion_code,
        trial_end: upgrading? ? 'now' : current_subscription.paid_through_date&.to_time&.to_i
      )
    end
  end

  def existing_stripe_subscription
    @existing_stripe_subscription ||= begin
      subscription = current_organization.upcoming_subscription || current_subscription
      Stripe::Subscription.retrieve(subscription.stripe_subscription_id)
    end
  end

  def save_subscription(stripe_subscription)
    subscription = authorize Subscription.build_from(
      current_organization, plan_category, stripe_subscription, mark_pending: !upgrading?
    )
    current_organization.add_credits(subscription)
    current_organization.save
    current_organization.reload
    subscription.save

    BillingMailer.with(
      user: current_user,
      subscription: subscription
    ).subscription_transaction_email.deliver_later
  end

  def cancel_all_subscriptions
    current_organization.subscriptions.reload.map(&:cancel).all?
  end

  def reconcile_local_subscriptions!
    cancel_method = :cancel if current_subscription.braintree_subscription_id? # TODO: Remove in TR#1248
    cancel_method ||= upgrading? ? :upgrade : :cancel_locally!
    current_organization.subscriptions.reload.map(&cancel_method).all?
  end

  def after_subscription_url
    redirect_path = session.delete :subscription_redirect_to
    return redirect_path if redirect_path

    policy(Event).manage? ? manage_events_url : leader_boards_url
  end

  # Remaining is a positive amount, so we need it to be a negative to be credited
  # TODO: Remove in TR#1248
  def apply_remaining_balance_from_current_subscription!
    return unless upgrading?

    Stripe::InvoiceItem.create(
      customer: current_organization.verified_stripe_customer_id,
      currency: 'usd',
      description: "Remaining credit on #{current_subscription.display_name}",
      amount: -(current_subscription.remaining_balance * 100).to_i
    )
  end

  def validated_promotion_code
    promotion_valid = SubscriptionPlan.active_promotions(promotion_code: promotion_code)&.key?(plan_id_params)
    promotion_valid ? promotion_code : nil
  end

  def plan_id_params
    params[:plan_id]
  end

  def league_notice_not_clicked?
    params[:league_gym_notice].present?
  end

  def promotion_code
    params[:promotion_code]&.strip&.upcase
  end

  def payment_source
    return if params[:payment_method_token].blank?

    PaymentSource.new(current_organization, params[:payment_method_token]).source
  end

  def plan_category
    {
      'league-gym-yearly': SubscriptionPlan::LeagueGym.to_s,
      'league-gym-biannually': SubscriptionPlan::LeagueGym.to_s,
      'league-gym-quarterly': SubscriptionPlan::LeagueGym.to_s,
      'league-gym-monthly': SubscriptionPlan::LeagueGym.to_s,
      'gym-yearly': SubscriptionPlan::Gym.to_s,
      'gym-biannually': SubscriptionPlan::Gym.to_s,
      'gym-quarterly': SubscriptionPlan::Gym.to_s,
      'gym-monthly': SubscriptionPlan::Gym.to_s,
      'individual-yearly': SubscriptionPlan::Individual.to_s,
      'individual-biannually': SubscriptionPlan::Individual.to_s,
      'individual-quarterly': SubscriptionPlan::Individual.to_s,
      'individual-monthly': SubscriptionPlan::Individual.to_s,
      'participant-yearly': SubscriptionPlan::Participant.to_s,
      'participant-biannually': SubscriptionPlan::Participant.to_s,
      'participant-quarterly': SubscriptionPlan::Participant.to_s,
      'participant-monthly': SubscriptionPlan::Participant.to_s
    }[plan_id_params&.to_sym]
  end
end
