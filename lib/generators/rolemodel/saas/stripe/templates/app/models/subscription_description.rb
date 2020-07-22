# frozen_string_literal: true

class SubscriptionDescription < ApplicationRecord
  belongs_to :subscription
  validates :action, presence: true
  validates :reason, presence: true
end
