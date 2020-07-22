# frozen_string_literal: true

class TicketItem < RegistrationItem
  belongs_to :ticket

  def name
    ticket_description
  end

  def description
    ticket_description
  end

  def secondary_description
    ticket.comment
  end

  def unit_price
    ticket.price
  end

  def fixed_convenience_fee
    unit_price.zero? ? 0 : RegistrationPricing::FIXED_CONVENIENCE_FEE_PER_SIMPLE_TICKET
  end

  def convenience_fee_percentage
    RegistrationPricing::SIMPLE_TICKET_CONVENIENCE_FEE_PERCENTAGE
  end

  private

  def ticket_description
    "#{ticket.name} x#{quantity}"
  end
end
