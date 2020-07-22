# frozen_string_literal: true

module StripeHooks
  class Account < Base
    # If the organization deauthorized Connect, blank out their account id.
    def process
      return unless event.type == 'account.application.deauthorized'

      Organization
        .find_by(stripe_account_id: event.account)
        &.update(stripe_account_id: nil)
    end
  end
end
