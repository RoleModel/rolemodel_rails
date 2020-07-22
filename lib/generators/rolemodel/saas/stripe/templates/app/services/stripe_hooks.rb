# frozen_string_literal: true

module StripeHooks
  def self.process_event(event)
    return unless event.present? # Example: No matching signing signature

    hook_class = event.type.split('.').first.classify
    return unless const_defined?(hook_class, false)

    const_get(hook_class, false).new(event).process
  end
end
