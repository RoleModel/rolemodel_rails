FactoryBot.define do
  factory :user do
    first_name { "Default" }
    last_name { "User" }
    sequence :email do |n|
      "person#{n}@example.com"
    end
    organization

    password { 'password123' }
    password_confirmation { password }

    trait :regular_user do
      first_name { "Regular" }
      last_name { "User" }
      role { 'user' }
    end

    trait :org_admin do
      first_name { "Org" }
      last_name { "Admin" }
      role { 'org_admin' }
    end

    trait :support_admin do
      first_name { "Support" }
      last_name { "Admin" }
      role { 'support_admin' }
    end
  end
end
