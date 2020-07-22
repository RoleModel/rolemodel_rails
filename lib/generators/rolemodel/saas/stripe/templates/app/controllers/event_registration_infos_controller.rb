# frozen_string_literal: true

class EventRegistrationInfosController < AuthenticationController
  def update
    @event_registration_info = authorize EventRegistrationInfo.find(params[:id])

    if @event_registration_info.update(event_registration_info_params)
      respond_to do |format|
        format.html { redirect_to options_event_path(@event_registration_info.event), notice: 'Event Public Details were successfully updated.' }
        format.json { head :ok }
      end
    else
      @event = @event_registration_info.event
      render 'events/publicize'
    end
  end

  def update_price
    @event_registration_info = authorize EventRegistrationInfo.find(params[:id])
    @event = @event_registration_info.event

    if @event_registration_info.update(price_params)
      render json: @event_registration_info.as_json(only: %i[id price price_name price_comment])
    else
      render json: { errors: @event_registration_info.errors.full_messages }, status: :bad_request
    end
  end

  private

  def event_registration_info_params
    params.require(:event_registration_info).permit(
      :description,
      :address,
      :photo,
      :league_member_discount,
      event_attributes: [:enable_registration]
    )
  end

  def price_params
    params.require(:event_registration_info).permit(
      :price,
      :price_name,
      :price_comment,
    )
  end
end
