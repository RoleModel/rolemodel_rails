# frozen_string_literal: true

class RegistrationItem < ApplicationRecord
  belongs_to :registration_order

  scope :without_tickets, -> { where.not(type: 'TicketItem') }

  validates :type, :quantity, presence: true

  before_create :set_convenience_fees

  def type_prefixed_name
    "#{type.sub('Item', '')}: #{name}"
  end

  def secondary_description
    nil
  end

  def refunded?
    refunded_amount? || (recorded_price&.zero? && Refund.for_item(id).exists?)
  end

  # TODO: reconsider if this is the place to determine this
  def registration_price
    unit_price * quantity
  end

  def as_json(options = {})
    super(options).merge(
      paid: registration_order.paid?,
      type: type
    )
  end

  def refund!()
    # Skip validation since we've already processed refund remotely, so we
    # should record relevant amounts regardless of validation errors. Since
    # validation errors generally means someone updated Event Tags after a
    # contestant registered, the validation errors aren't very meaningful at
    # this point.
    update_columns(refunded_amount: recorded_price, gym_revenue: 0)
  end

  def record_pricing!
    update(
      recorded_price: registration_price,
      gym_revenue: registration_price
    )
  end

  private

  # Ticket price * Percentage then add Fixed fee and multiply by quantity ordered
  def set_convenience_fees
    return unless convenience_fees.zero?

    self.convenience_fees = ((unit_price * convenience_fee_percentage + fixed_convenience_fee) * quantity).round(2)
  end
end
