# frozen_string_literal: true

class Admin::SubscriptionsController < AuthenticationController
  def edit
    @subscription = Subscription.includes(:subscription_descriptions).find(params[:id])
    authorize @subscription, :admin_edit?
  end

  def update
    subscription = Subscription.find(params[:id])
    authorize subscription, :admin_edit?
    subscription.assign_attributes(subscription_params)
    if subscription.save
      flash[:notice] = 'The Subscription was successfully updated'
      redirect_to admin_organization_path(subscription.organization_id)
    else
      flash[:notice] = subscription.errors.full_messages.to_sentence
      redirect_to edit_admin_subscription_path
    end
  end

  private

  def subscription_params
    params.require(:subscription).permit(
      :paid_through_date,
      :next_billing_date,
      :status,
      :plan_category,
      subscription_descriptions_attributes: [
        :action,
        :reason
      ]
    ).to_h.tap do |hash|
      hash[:plan_category] = 'SubscriptionPlan::' + hash[:plan_category].sub(' ', '')
    end
  end
end
