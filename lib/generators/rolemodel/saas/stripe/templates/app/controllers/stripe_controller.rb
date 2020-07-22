# frozen_string_literal: true

class StripeController < AuthenticationController
  skip_before_action :authenticate_user!, :verify_authenticity_token, only: :webhooks
  skip_after_action :verify_authorized, only: :webhooks

  # Handle Stripe OAuth from the My Account page
  def organization_oauth
    if params[:code].present?
      handle_oauth_for(current_organization)
    else
      authorize current_organization, :edit?
      flash[:error] = params[:error_description]
    end
    redirect_to organization_path
  end

  # Handle Stripe OAuth from an Event Options page
  def event_oauth
    event = authorize Event.find(params[:state]), :edit?
    if params[:code].present?
      handle_oauth_for(event.organization)
    else
      flash[:error] = params[:error_description]
    end
    redirect_to options_event_path(event)
  end

  def webhooks
    StripeHooks.process_event(webhook_event)
    head :ok
  end

  private

  def handle_oauth_for(organization)
    authorize organization, :edit?
    oauth_response = Stripe::OAuth.token(code: params[:code], grant_type: 'authorization_code')
    organization.update!(
      stripe_account_id: oauth_response.stripe_user_id
    )
    flash[:notice] = 'Stripe Account successfully linked!'
  rescue Stripe::OAuth::OAuthError => e
    flash[:error] = e.message
  end

  # There are two kinds of Webhook: Account (things which happen on the NM
  # account) and Connect (things which happen related to a gym account). We need
  # to monitor both webhooks for data completeness. However, each has its own
  # secret keys which we need to verify authenticity of the request with. Thus,
  # this method tries to verify against both (if provided) but is allowed to
  # ignore any verification error.
  def webhook_event
    ENV
      .values_at('STRIPE_WEBHOOK_ACCOUNT_HOOKS_SECRET', 'STRIPE_WEBHOOK_CONNECT_HOOKS_SECRET')
      .compact
      .each do |signing_secret|
        return Stripe::Webhook.construct_event(
          request.body.read,
          request.headers['Stripe-Signature'],
          signing_secret
        )
      rescue Stripe::SignatureVerificationError
      end
  end
end
