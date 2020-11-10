require 'rails_helper'

RSpec.describe SubscriptionDescription, type: :model do
  it 'documents why RoleModel manually modified their subscription' do
    subscription_description = build(:subscription_description)
    expect(subscription_description).to be_valid
  end

  it 'is invalid without naming the action taken' do
    subscription_description = build(:subscription_description, action: '')
    expect(subscription_description).not_to be_valid
  end

  it 'is invalid without giving a reason why we did it' do
    subscription_description = build(:subscription_description, reason: '')
    expect(subscription_description).not_to be_valid
  end
end
