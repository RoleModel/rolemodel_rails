# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StripeHooks::Charge do
  describe '#process' do
    it 'returns nil for event types we do not care about' do
      event = event(type: 'charge.refunded')
      expect(described_class.new(event).process).to eq nil
    end

    it 'returns nil if event is not in livemode' do
      event = event(livemode: false)
      expect(described_class.new(event).process).to eq nil
    end

    it 'alerts HoneyBadger if the refund is failed and livemode is true' do
      allow(Honeybadger).to receive(:notify)
      described_class.new(event(livemode: true)).process

      expect(Honeybadger).to have_received(:notify)
    end
  end

  def event(**options)
    Stripe::Event.construct_from({
      id: 'evt_1FAdx7CehPrJAqhpfZUEAWFR',
      object: 'event',
      api_version: '2019-08-14',
      data: {
        object: {
          id: 're_1FAdx4CehPrJAqhpyzeZLVWy',
          object: 'refund',
          amount: 3000,
          charge: 'ch_1FAdw6CehPrJAqhpWzmI5Nye',
          currency: 'usd',
          failure_reason: 'expired_or_canceled_card',
          metadata: {
            refunded_by_id: '8',
            refunded_by_email: 'ninjamastersupport@rolemodelsoftware.com'
          },
          reason: nil,
          receipt_number: nil,
          source_transfer_reversal: nil,
          status: 'failed',
          transfer_reversal: nil
        },
        previous_attributes: {
          failure_balance_transaction: nil,
          failure_reason: nil,
          status: 'succeeded'
        }
      },
      livemode: false,
      type: 'charge.refund.updated'
    }.merge(options))
  end
end
