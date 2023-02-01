# frozen_string_literal: true

FactoryBot.define do
  factory :blazer_query, class: Blazer::Query do
    association :creator, factory: :user
    sequence(:name) { |n| "Query #{n}" }
    statement { 'select * from users' }
    data_source { 'main' }
    status { 'active' }
  end
end
