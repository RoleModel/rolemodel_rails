# frozen_string_literal: true

class EventRegistrationsController < AuthenticationController
  layout 'registration'

  rescue_from Stripe::StripeError, with: :payment_failure

  prepend_before_action :store_user_location!, only: :new

  before_action :set_event, except: :show
  before_action :set_registration_order, except: %i[show confirmation]
  before_action :set_tickets, except: %i[show confirmation] # TODO: this will eventually be configured during event creation

  skip_before_action :authenticate_user!, only: :show
  skip_after_action :verify_authorized, only: :show

  def show
    begin
      @event = Event.uses_registration.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      if RegistrationOrder.where(event_id: params[:id]).any?
        @event = Event.find params[:id]
        @event.registration_closed_at = 1.day.ago unless @event.registration_closed_at
      end
    end

    if @event.virtual?
      authenticate_user!
    end

    @organization = @event.organization
  end

  def new
    registered_athletes_ids = @registration_order.contestant_items.pluck(:athlete_id)
    unregistered_athletes = current_user.athletes.where.not(id: registered_athletes_ids).map { |athlete| athlete.json_for_event(@event) }
    athletes_with_items = @registration_order.registration_items.without_tickets.map { |item| item.athlete.json_for_event(@event, item) }

    @athletes = unregistered_athletes + athletes_with_items
  end

  def create
    athlete = current_user.athletes.find(params[:athlete_id])

    registration_item = athlete.registration_items.find_or_initialize_by(
      type: 'ContestantItem',
      registration_order: @registration_order
    )
    registration_item.assign_attributes(
      quantity: 1,
      tags: params[:tag_config].join(' ')
    )

    if registration_item.save
      render json: athlete.json_for_event(@event)
    else
      render json: { message: registration_item.errors.full_messages.join('\n') }, status: :bad_request
    end
  end

  def update_ticket
    ticket = Ticket.find(params[:ticket_id])

    registration_item = @registration_order.ticket_items.find_or_initialize_by(ticket: ticket)

    if params[:quantity].to_i.zero?
      registration_item.destroy!
      return render json: ticket.as_json(registration_item_for_order: @registration_order)
    end

    if registration_item.update(quantity: params[:quantity])
      render json: ticket.as_json(registration_item_for_order: @registration_order)
    else
      render json: { message: I18n.t('event_registrations.errors.update_ticket') }, status: :bad_request
    end
  end

  def destroy
    registration_item = @registration_order.registration_items.find_by!(id: params[:itemId])
    registration_item.destroy!
    respond_to do |format|
      format.json { head :no_content }
      format.html do
        redirect_back(
          fallback_location: contestants_registration_event_path(@event),
          notice: "#{registration_item.athlete.name} has been unregistered from #{@event.name}")
      end
    end
  end

  def checkout
    @price = RegistrationPricing.new(@registration_order)
  end

  def apply_promo_code
    promo_code = @event.registration_info.promotional_codes.find_by(name: params[:promo_code].downcase.strip)

    if promo_code
      @registration_order.update(promotional_code: promo_code)
      redirect_to checkout_event_url(@event), notice: "Applied promo code #{promo_code.name}"
    else
      redirect_to checkout_event_url(@event), notice: "Could not find promo code #{params[:promo_code]}"
    end
  end

  def process_payment
    return no_registration_items_redirect if @registration_order.registration_items.none?

    terms = params.dig(:registration, :agreed_to_terms)
    return not_agreed_to_terms_redirect if !terms || terms == '0'

    payment_source = PaymentSource.new(@registration_order.user, params[:payment_method_token])

    if @registration_order.membership_items.any?
      @registration_order.pending_membership_athlete_ids = @registration_order.membership_items.map(&:athlete_id)
      @membership_order = current_user.registration_orders.create(transaction_id: nil)
      @registration_order.membership_items.update(registration_order: @membership_order)

      RegistrationPricing.new(@membership_order, payment_source).process
    end

    if @registration_order.registration_items.any?
      RegistrationPricing.new(@registration_order, payment_source).process
    end

    order_ids = [@registration_order.id, @membership_order&.id].compact.join(',')
    redirect_to confirmation_registration_orders_path(order_ids)
  end

  private

  def set_event
    @event = authorize Event.uses_registration.find(params[:id]), :register?
  end

  def set_registration_order
    # empty gateway transaction means it's unpaid. Any better way to represent that?
    @registration_order = current_user.registration_orders.find_or_create_by(
      event: @event,
      transaction_id: nil
    )
  end

  def set_tickets
    @tickets = @event.tickets.as_json(registration_item_for_order: @registration_order)
  end

  def store_user_location!
    store_location_for(:user, request.fullpath)
  end

  def no_registration_items_redirect
    flash[:error] = I18n.t 'event_registrations.errors.no_registration_items'
    redirect_to contestants_registration_event_path(@event)
  end

  def not_agreed_to_terms_redirect
    flash[:error] = I18n.t 'event_registrations.errors.not_agreed_to_terms'
    redirect_back fallback_location: checkout_event_path(@event)
  end

  def total_registration_cost(contestants)
    contestants.sum(&:registration_price)
  end

  def payment_failure(exception)
    Rails.logger.error "#{exception.code} - #{exception.message}"
    flash[:error] = I18n.t('event_registrations.errors.process_payment', message: exception.message)
    redirect_back fallback_location: checkout_event_path(@event)
  end
end
