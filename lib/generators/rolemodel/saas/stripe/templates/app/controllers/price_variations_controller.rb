# frozen_string_literal: true

class PriceVariationsController < AuthenticationController
  def create
    @event_registration_info = EventRegistrationInfo.find(params[:registration_info_id])
    @price_variation = authorize @event_registration_info.price_variations.build(price_variation_params)

    if @price_variation.save
      render json: @price_variation
    else
      render json: { errors: @price_variation.errors.full_messages }, status: :bad_request
    end
  end

  def update
    @price_variation = authorize PriceVariation.find(params[:id])

    if @price_variation.update(price_variation_params)
      render json: @price_variation
    else
      render json: { errors: @price_variation.errors.full_messages }, status: :bad_request
    end
  end

  private

  def price_variation_params
    params.require(:price_variation).permit(:price, :name, :comment, :tags)
  end
end
