# frozen_string_literal: true

Sentry.init do |config|
  config.dsn = ENV['SENTRY_DSN']
  config.enable_logs = true
  config.debug = Rails.env.local?

  # Traces sampling — 5% for HTTP requests, 10% for other transactions
  config.traces_sampler = lambda do |sampling_context|
    transaction_context = sampling_context[:transaction_context]

    case transaction_context[:op]
    when /^http/
      0.05
    else
      0.10
    end
  end

  # Enable profiling at 100% of sampled transactions
  config.profiles_sample_rate = 1.0

  # Breadcrumbs configuration
  config.breadcrumbs_logger = [:sentry_logger, :http_logger]

  # Exclude common noisy exceptions
  config.excluded_exceptions += [
    'ActiveRecord::RecordNotFound',
    'ActionController::RoutingError',
  ]

  # Include local variables for debugging
  config.include_local_variables = true

  # Filter out health check transactions
  config.before_send_transaction = lambda do |event, _hint|
    return nil if event.transaction&.match?(/health|ping|metrics/)
    event
  end

  # Filter sensitive data using Rails' parameter filter
  filter = ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters)
  config.send_default_pii = false

  config.before_send = lambda do |event, _hint|
    if event.extra
      event.extra = filter.filter(event.extra)
    end

    if event.user
      event.user = filter.filter(event.user)
    end

    if event.contexts
      event.contexts = filter.filter(event.contexts)
    end

    event
  end

  config.enabled_patches << :logger
  config.std_lib_logger_filter = proc do |_logger, _message, severity|
    [:warn, :error, :fatal].include?(severity)
  end

  config.rails.register_error_subscriber = Rails.env.production?
  config.rails.structured_logging.subscribers = {
    action_controller: Sentry::Rails::LogSubscribers::ActionControllerSubscriber,
  }
end
