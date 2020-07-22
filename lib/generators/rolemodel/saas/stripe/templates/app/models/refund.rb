# frozen_string_literal: true

class Refund < ApplicationRecord
  scope :for_item, ->(id) { where('? = ANY (registration_items)', id) }

  belongs_to :refunded_by, class_name: 'User'

  class ItemSerializer
    def self.load(values)
      RegistrationItem.find(Array.wrap(values))
    end

    def self.dump(values)
      Array.wrap(values).map do |item|
        item.is_a?(RegistrationItem) ? item.id : item
      end
    end
  end

  belongs_to :registration_order

  serialize :registration_items, ItemSerializer

  delegate :transaction_id, to: :registration_order, prefix: :original

  def request_refund!(convenience_fees = false)

    process_refund(convenience_fees).tap do |result|
      update(
        transaction_id: result[:id],
        total: result[:amount]
      )
      registration_items.each { |item| item.refund! }

      registration_order.refund!(result[:convenience_fees_refunded])
    end
  end

  def requested_refund_amount(convenience_fee = 0)
    all_recored_prices = registration_items.sum(&:recorded_price)
    all_recored_prices + convenience_fee
  end

  private

  def all_items_selected?
    registration_items.count == registration_order.registration_items.count
  end

  def process_refund(convenience_fees)
    prior_order_status = original_invoice.status
    # Draft and open invoices can only be refunded in full
    if all_items_selected? && prior_order_status == 'draft'
      process_draft_order_refund(convenience_fees)
    elsif all_items_selected? && prior_order_status == 'open'
      process_open_order_refund(convenience_fees)
    else
      process_paid_order_refund(convenience_fees)
    end
  end

  def process_draft_order_refund(_)
    Rails.logger.debug "Deleting Transaction for Order #{registration_order.padded_id}!"
    stripe_invoice = Stripe::Invoice.delete(original_transaction_id, {}, stripe_account: connected_account)
    {
      id: stripe_invoice.id,
      amount: registration_order.purchase_total,
      convenience_fees_refunded: registration_order.convenience_fees
    }
  end

  def process_open_order_refund(_)
    Rails.logger.debug "Voiding Transaction for Order #{registration_order.padded_id}!"
    stripe_invoice = Stripe::Invoice.void_invoice(original_transaction_id, {}, stripe_account: connected_account)
    {
      id: stripe_invoice.id,
      amount: stripe_invoice.total,
      convenience_fees_refunded: registration_order.convenience_fees
    }
  end

  def process_paid_order_refund(convenience_fees)
    convenience_fees_refunded = convenience_fees ? registration_order.convenience_fees : 0
    Rails.logger.debug "Refunding $#{requested_refund_amount(convenience_fees_refunded)} for Order #{registration_order.padded_id}"
    stripe_refund = Stripe::Refund.create({
      charge: original_invoice.charge,
      amount: (requested_refund_amount(convenience_fees_refunded) * 100).to_i,
      refund_application_fee: convenience_fees,
      metadata: {
        refunded_by_id: refunded_by_id,
        refunded_by_email: refunded_by.email
      }
    }, stripe_account: connected_account)
    {
      id: stripe_refund.id,
      amount: stripe_refund.amount,
      convenience_fees_refunded: convenience_fees_refunded
    }
  end

  def original_invoice
    @original_invoice ||=
      Stripe::Invoice.retrieve(original_transaction_id, stripe_account: connected_account)
  end

  def connected_account
    registration_order.event&.organization&.stripe_account_id
  end
end
