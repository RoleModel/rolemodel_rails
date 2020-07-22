# frozen_string_literal: true

class PromotionalCode < ApplicationRecord
  belongs_to :event_registration_info, optional: true
  has_many :registration_orders, dependent: :restrict_with_exception

  validates :name, :adjustment_type, :adjustment, presence: true

  enum adjustment_type: { fixed: 'Fixed', percentage: 'Percentage' }

  def name=(value)
    super(value.downcase.strip)
  end
end
