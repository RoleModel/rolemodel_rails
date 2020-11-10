# frozen_string_literal: true

class TicketsController < AuthenticationController
  def create
    @event = Event.find(params[:event_id])
    @ticket = authorize @event.tickets.build(ticket_params)

    if @ticket.save
      render json: @ticket
    else
      render json: { errors: @ticket.errors.full_messages }, status: :bad_request
    end
  end

  def update
    @ticket = authorize Ticket.find(params[:id])

    if @ticket.update(ticket_params)
      render json: @ticket
    else
      render json: { errors: @ticket.errors.full_messages }, status: :bad_request
    end
  end

  private

  def ticket_params
    params.require(:ticket).permit(:price, :name, :comment)
  end
end
