# frozen_string_literal: true

class RegistrationOrdersController < AuthenticationController
  skip_after_action :verify_authorized, only: [:confirmation, :refund_all]

  before_action :set_order_and_event, except: [:confirmation, :refund_all]

  rescue_from Stripe::StripeError, with: :refund_failure

  # TODO: Only settled transactions can be refunded. Otherwise, they must be
  # voided, which can only be done for the full transaction amount!

  def show; end

  def edit; end

  def refund
    Refund.new(
      refunded_by: current_user,
      registration_order: @order,
      registration_items: params[:items_for_refund],
      waive_refund_fee: true
    ).request_refund!

    BillingMailer.with(
      user: @order.user,
      order: @order
    ).refund_email.deliver_later
    redirect_to edit_registration_order_path(@order), notice: 'Successfully refunded!'
  end

  def refund_all
    event = Event.find(params[:event_id])
    event.registration_orders.paid.each do |order|
      next if order.refunds.count != 0

      total = order.base_price * order.convenience_fees

      Refund.new(
      refunded_by: current_user,
      registration_order: order,
      total: total,
      registration_items: order.registration_items,
      waive_refund_fee: true
      ).request_refund!(true)

      BillingMailer.with(
        user: order.user,
        order: order
      ).refund_email.deliver_later

      order.refund!(order.convenience_fees)
    end

    redirect_to options_event_path(event.id), notice: 'All Registration Orders successfully refunded!'
  end

  def confirmation
    order_ids = params[:registration_order_ids].to_s.split(',')
    @orders = current_user.registration_orders.paid.where(id: order_ids)
  end

  private

  def set_order_and_event
    @order = authorize RegistrationOrder.find(params[:id])
    @event = @order.event
  end

  def refund_failure(exception)
    Rails.logger.error "#{exception.code} - #{exception.message}"
    if params[:action] == "refund_all"
      flash[:error] = "Unable to refund all orders: #{exception.message}"
      redirect_to registration_orders_event_path(params[:event_id])
    else
      flash.now[:error] = "Unable to refund: #{exception.message}"
      render :edit
    end
  end
end
