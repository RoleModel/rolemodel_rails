# frozen_string_literal: true

Rails.application.configure do
  config.lograge.enabled = true
  config.lograge.custom_payload do |controller|
    {
      user_id: controller.current_user.try(:id)
    }
  end
  config.lograge.custom_options = lambda do |event|
    exceptions = %w[controller action format id]
    {
      params: event.payload[:params].except(*exceptions)
    }
  end
end
