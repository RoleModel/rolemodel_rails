# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StripeHooks::Account do
  describe '#process' do
    it 'returns nil for event types we do not care about' do
      event = event(type: 'account.application.authorized')
      expect(described_class.new(event).process).to eq nil
    end

    it 'returns nil if no matching organization is found (rather than an error)' do
      event = event(account: 'acct_NotFound')
      expect(described_class.new(event).process).to eq nil
    end

    it 'sets the stripe account id to nil for a matching account' do
      account_id = 'acct_1F9daoCCeQjWZWpv'
      organization = create(:organization, stripe_account_id: account_id)
      described_class.new(event(account: account_id)).process

      expect(organization.reload.stripe_account_id).to eq nil
    end
  end

  def event(**options)
    Stripe::Event.construct_from({
      id: 'evt_1FAdBdCCeQjWZWpv5iar80hC',
      object: 'event',
      account: 'acct_1F9daoCCeQjWZWpv',
      api_version: '2019-05-16',
      data: {
        object: {
          id: 'ca_FaUDf1681CjyK92mz5UPu3NSYLhTiLdv',
          object: 'application',
          name: 'Ninja Master'
        }
      },
      livemode: false,
      type: 'account.application.deauthorized'
    }.merge(options))
  end
end
