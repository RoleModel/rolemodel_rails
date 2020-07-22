# frozen_string_literal: true

class RegistrationPricing
  # CONVENIENCE fees are charged by the Payment Gateway and are passed on to the customer
  # See RegistrationItem#convenience_fees
  FIXED_CONVENIENCE_FEE_PER_PARTICIPANT = 1.59 # e.g. Athlete Ticket
  FIXED_CONVENIENCE_FEE_PER_SIMPLE_TICKET = 0.79 # e.g. Spectator Ticket
  PARTICIPANT_CONVENIENCE_FEE_PERCENTAGE = 3.5 / 100
  SIMPLE_TICKET_CONVENIENCE_FEE_PERCENTAGE = 2.0 / 100
  # PLATFORM PROCESSING fees are charged to event coordinators by us
  PLATFORM_PROCESSING_PERCENTAGE_FEE = 2.5 / 100
  # User should eat the cost of stripe transaction when refunding
  REFUND_PERCENTAGE_FEE = 5.0 / 100

  attr_reader :registration_order, :payment_source

  def initialize(registration_order, payment_source = nil)
    @registration_order = registration_order
    @payment_source = payment_source
  end

  def line_items
    registration_order.registration_items
  end

  def process
    # Braintree used to only accept non-zero amounts, but while Stripe seems not
    # to have this limitation, we didn't want to introduce this change here yet
    result = process_payment if total_price.positive?

    registration_order.finalize!(result&.id, self)
    BillingMailer.with(
      user: registration_order.user,
      order: registration_order
    ).registration_order_email.deliver_later

    result
  end

  def base_price
    @base_price ||= line_items.sum(&:registration_price).round(2)
  end

  def total_convenience_fees
    @total_convenience_fees ||= line_items.sum(&:convenience_fees)
  end

  def total_price
    (base_price + total_convenience_fees).round(2)
  end

  def total_processing_fees
    return 0 unless total_price.positive?

    charge = Stripe::Charge.retrieve(invoice.charge, stripe_account: connected_account_id)
    balance_transaction = Stripe::BalanceTransaction.retrieve(
      charge.balance_transaction, stripe_account: connected_account_id
    )
    # Breakdown w/ amount and description (AND type = 'stripe_fee' || 'application_fee')
    # Amount is in cents, so divide by 100
    balance_transaction.fee_details.detect { |fee| fee.type == 'stripe_fee' }.amount.to_f / 100
  end

  private

  def process_payment
    # Invoice must have an item before it can be created, so make an empty item
    create_invoice_item(with_invoice: false)

    # Instantiate an invoice to assign our real invoice items to
    invoice

    prepare_line_items!

    # create and finalize an invoice, prompting payment processing
    pay_invoice!
  end

  def invoice
    @invoice ||= begin
      # Create the invoice...
      invoice = Stripe::Invoice.create({
        customer: connected_customer_id,
        description: registration_order.name,
        statement_descriptor: statement_descriptor,
        default_source: payment_source.source(connected_account_id),
        # TODO: Is this the right approach?
        # If we aren't working with a Connected gym account, we can't take application fees.
        application_fee_amount: connected_account_id ? (total_convenience_fees * 100).to_i : nil
      }, stripe_account: connected_account_id)
      # Then delete any associated items, so we start fresh
      invoice.lines.each do |item|
        Stripe::InvoiceItem.delete(item.id, {}, stripe_account: connected_account_id)
      end
      invoice
    end
  end

  def prepare_line_items!
    # prepare line items for the invoice
    line_items.each do |item|
      create_invoice_item(
        quantity: item.quantity,
        unit_amount: (item.unit_price * 100).to_i,
        description: item.description
      )
    end
    create_invoice_item(
      description: 'Convenience Fees',
      unit_amount: (total_convenience_fees * 100).to_i
    )
  end

  def create_invoice_item(with_invoice: true, **params)
    Stripe::InvoiceItem.create({
      customer: connected_customer_id,
      invoice: with_invoice ? invoice : nil,
      currency: 'usd',
      quantity: 1,
      unit_amount: 0
    }.merge(params), stripe_account: connected_account_id)
  end

  def pay_invoice!
    invoice.pay # This updates invoice in place with a charge ID if successful
  rescue Stripe::StripeError
    # If payment fails, delete the invoice so it doesn't try to charge again later
    invoice.void_invoice
    raise
  end

  def connected_customer_id
    @connected_customer_id ||= payment_source.connected_customer_id(connected_account_id)
  end

  def connected_account_id
    @connected_account_id ||= connected_account&.id
  end

  def connected_account
    @connected_account ||= payment_source.connected_account(registration_order)
  end

  def statement_descriptor
    return if connected_account.blank?

    prefix = connected_account.settings.payments.statement_descriptor.first(19)
    raise 'this needs to be changed' # "#{prefix}*NM"
  end
end
