# frozen_string_literal: true

# Make test output cleaner by disabling Stripe logging.
# Temporarily re-enable it if you need to debug a test.
Stripe.log_level = nil

module Stripe
  module TestHelpers
    # https://stripe.com/docs/testing#sources
    EXPIRATIONS = {
      valid: 1.year.from_now.strftime('%m/%y'),
      invalid: 1.year.ago.strftime('%m/%y')
    }.freeze

    VALID_CVC = '123'
    INVALID_CVC = '12'

    VALID_ZIP = '12345'

    CARDS = {
      successful: '4000000000000077', # Charge succeeds, funds added to balance
      declined: '4000000000000002' # Card declined
    }.freeze

    TOKENS = {
      successful: 'tok_visa',
      declined: 'tok_chargeDeclined'
    }.freeze

    TEST_CONNECT_ACCOUNT_ID = 'acct_1F88POCV8PtdY8t9'

    def self.fill_in_card_details(page, card: :successful, expiration: :valid)
      fill_in_card_number(page, card)
      fill_in_card_expiration(page, expiration)
      page.fill_in 'cvc', with: VALID_CVC
      page.fill_in 'postal', with: VALID_ZIP
    end

    def self.fill_in_card_number(page, card = :successful)
      fill_in_stripe_field(page, 'cardnumber', Stripe::TestHelpers::CARDS[card])
    end

    def self.fill_in_card_expiration(page, validity = :valid)
      fill_in_stripe_field(page, 'exp-date', Stripe::TestHelpers::EXPIRATIONS[validity])
    end

    # For some reason, the Stripe form will jumble the numbers for the card
    # and give invalid cards sometimes. This helps ensures the correct number is
    # entered every time.
    def self.fill_in_stripe_field(page, field_name, value)
      field = page.find_field(field_name)
      value.chars.each do |piece|
        field.send_keys(piece)
      end
    end
  end
end
