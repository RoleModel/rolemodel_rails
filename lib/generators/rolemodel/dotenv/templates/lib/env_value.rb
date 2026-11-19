# frozen_string_literal: true

# Reads typed settings from ENV. A blank value counts as unset. When it is unset, the
# default comes from the first of these that applies: a key named for the current
# environment, `local:` in development and test, the block, then `default:`.
#
#   EnvValue.string('DEFAULT_URL') { 'http://localhost:3000' }
#   EnvValue.string('API_CLIENT_ID', local: 'dev-client-id')
#   EnvValue.string!('FROM') # raises KeyError when unset, ArgumentError when blank
#   EnvValue.url('DEFAULT_URL') # raises ArgumentError without a scheme and host
#   EnvValue.string('ENCRYPTION_KEY', default: 'dev-key', production: nil)
#   EnvValue.array('REPORT_EMAILS', default: %w[someone@example.com])
#   EnvValue.boolean('FEATURE_ON', default: true)
module EnvValue
  ENVIRONMENTS = %i[development test staging production local default].freeze
  TRUE_WORDS = %w[true t 1 yes y on enabled].freeze
  FALSE_WORDS = %w[false f 0 no n off disabled].freeze

  module_function

  def string(key, **defaults, &)
    read(key) || fallback(defaults, &)
  end

  def string!(key)
    ENV.fetch(key).presence || raise(ArgumentError, "#{key} is blank")
  end

  def url(key, **defaults, &)
    value = string(key, **defaults, &)
    return value if value.nil? || URI.parse(value).then { it.scheme && it.host }

    raise ArgumentError, "#{key} must be a full URL, like https://example.com, not #{value.inspect}"
  end

  def array(key, **defaults, &)
    value = read(key)
    value ? value.split(',').map(&:strip).compact_blank : fallback(defaults, &) || []
  end

  def boolean(key, **defaults, &)
    value = read(key)&.downcase
    return fallback(defaults, &) || false unless value
    return true if TRUE_WORDS.include?(value)
    return false if FALSE_WORDS.include?(value)

    raise ArgumentError, "#{key} must be one of #{(TRUE_WORDS + FALSE_WORDS).join(', ')}, not #{value.inspect}"
  end

  def read(key)
    ENV.fetch(key, nil).presence
  end

  def fallback(defaults)
    unknown = defaults.keys - ENVIRONMENTS
    raise ArgumentError, "unknown environment: #{unknown.join(', ')}" if unknown.any?

    environment = Rails.env.to_sym
    if defaults.key?(environment) then defaults[environment]
    elsif Rails.env.local? && defaults.key?(:local) then defaults[:local]
    elsif block_given? then yield
    else defaults[:default]
    end
  end
  private_class_method :read, :fallback
end
