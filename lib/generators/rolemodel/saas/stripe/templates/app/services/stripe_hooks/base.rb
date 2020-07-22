# frozen_string_literal: true

module StripeHooks
  class Base
    attr_reader :event

    def initialize(event)
      Rails.logger.debug(event)
      @event = event
    end

    def process; end
  end
end
