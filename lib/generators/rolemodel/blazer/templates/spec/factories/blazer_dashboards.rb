# frozen_string_literal: true

FactoryBot.define do
  factory :blazer_dashboard, class: Blazer::Dashboard do
    association :creator, factory: :user
    sequence(:name) { |n| "Dashboard #{n}" }
  end
end
