# frozen_string_literal: true

class RegistrationOrder < ApplicationRecord
  attr_writer :pending_membership_athlete_ids

  belongs_to :user
  belongs_to :event, optional: true
  belongs_to :promotional_code, optional: true

  has_many :registration_items
  has_many :membership_items
  has_many :contestant_items
  has_many :ticket_items
  has_many :refunds

  validates :user, presence: true

  scope :paid, -> { where.not(transaction_id: nil) }
  scope :order_by_user_names, -> { includes(:registration_items, :user).order('users.name asc') }

  EMPTY_TRANSACTION_ID = '-1'

  def paid?
    transaction_id.present?
  end

  def finalize!(transaction_id, price)
    update(
      payment_processor: transaction_id ? 'stripe' : nil,
      transaction_id: transaction_id || -1, # negative id for zero-dollar invoices w/o gateway representation
      base_price: price.base_price,
      convenience_fees: price.total_convenience_fees,
      processing_fees: price.total_processing_fees,
      purchase_total: price.total_price
    )

    registration_items.each do |item|
      item.record_pricing!
      item.register_athlete
    end
  end

  def season
    @season ||= membership_items.first&.season
  end

  def name
    return event.name if event?

    season ? season.description : "Order #: #{padded_id}"
  end

  def event?
    event_id?
  end

  def clear_unused_registration_items(season)
    return if transaction_id

    membership_items.where.not(season: season).destroy_all
  end

  def refund!(convenience_fees_refunded = 0)
    update(
      base_price: registration_items.where(refunded_amount: 0).sum(&:recorded_price).round(2),
      refunded_convenience_fees: convenience_fees_refunded
    )
  end

  def athlete_price_fixed_adjustment
    return promotional_code.adjustment if promotional_code&.fixed?

    0
  end

  def athlete_price_percentage_adjustment
    return promotional_code.adjustment if promotional_code&.percentage?

    1
  end

  def padded_id
    format('%08d', id)
  end

  def contestants_ordered
    contestant_items.count { |item| !item.refunded? }
  end

  def tickets_ordered
    ticket_items.sum { |item| !item.refunded? ? item.quantity : 0 }
  end

  def total_gym_revenue
    @total_gym_revenue ||= registration_items.sum(&:gym_revenue) - processing_fees
  end

  def pending_membership_athlete_ids
    @pending_membership_athlete_ids ||= membership_items.pluck(:athlete_id)
  end

  def pending_membership_for?(athlete_id)
    pending_membership_athlete_ids.include?(athlete_id)
  end

  def completely_refunded?
    base_price == 0.0
  end
end
