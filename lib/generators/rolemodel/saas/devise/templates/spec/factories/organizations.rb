# frozen_string_literal: true

FactoryBot.define do
  factory :organization do
    sequence :name do |n|
      "Organization #{n}"
    end
  end
end
