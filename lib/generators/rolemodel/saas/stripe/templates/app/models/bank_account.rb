# frozen_string_literal: true

class BankAccount < ApplicationRecord
  belongs_to :organization, inverse_of: :bank_account

  enum account_type: { business_checking: 'Business Checking', business_savings: 'Business Savings', personal_checking: 'Personal Checking', personal_savings: 'Personal Savings' }

  # some validation on account and routing numbers
  validates :name, :address, :email, :account_type, :encrypted_routing_number, :encrypted_routing_number_iv, :encrypted_account_number, :encrypted_account_number_iv, :remittance_email, presence: true
  validate :account_information

  attr_encrypted :account_number, key: ENV['ACCOUNT_NUMBER_KEY']
  attr_encrypted :routing_number, key: ENV['ROUTING_NUMBER_KEY']

  def account_information
    if routing_number.size == 9
      unless valid_routing_number?
        errors.add(:routing_number, 'needs to be a valid routing number')
      end
    else
      errors.add(:routing_number, 'must include 9 digits')
    end
  end

  private

  # source: https://github.com/Shopify/active_merchant/blob/master/lib/active_merchant/billing/check.rb#L57
  def valid_routing_number?
    digits = routing_number.to_s.scan(/\d/).map(&:to_i)
    return false unless digits.size == 9
    checksum = ((3 * (digits[0] + digits[3] + digits[6])) +
                (7 * (digits[1] + digits[4] + digits[7])) +
                     (digits[2] + digits[5] + digits[8])) % 10
    checksum == 0
  end
end
