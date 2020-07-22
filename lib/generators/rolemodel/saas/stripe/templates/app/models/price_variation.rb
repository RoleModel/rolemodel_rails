# frozen_string_literal: true

class PriceVariation < ApplicationRecord
  belongs_to :event_registration_info
  acts_as_list scope: :event_registration_info

  validates :event_registration_info, :tags, :price, :name, presence: true

  def tags=(value)
    value = value.split(',') if value.is_a?(String)
    super(value)
  end

  def match(registration_item)
    registration_tags = registration_item.tags.split
    tags.all? { |tag| registration_tags.include? tag }
  end
end
