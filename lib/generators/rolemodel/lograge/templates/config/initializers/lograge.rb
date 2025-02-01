# frozen_string_literal: true

if %w[development test].exclude?(Rails.env)
  Rails.application.configure do
    config.lograge.enabled = true
    config.lograge.custom_options = lambda do |event|
      exceptions = %w[controller action format id]
      {
        params: event.payload[:params].except(*exceptions),
        # user_id: controller.current_user.try(:id)
      }
    end
  end
end
