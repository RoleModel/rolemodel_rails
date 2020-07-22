# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StripeHooks do
  describe '.process_event' do
    it 'returns nil if no event is passed in' do
      expect(StripeHooks.process_event(nil)).to eq nil
    end

    it 'returns nil if no handler class is found' do
      event = OpenStruct.new(type: 'nonexistent.event.updated')
      expect(StripeHooks.process_event(event)).to eq nil
    end

    it 'returns nil if a class exists but it does not belong to this module' do
      event = OpenStruct.new(type: 'course.updated')
      expect(StripeHooks.process_event(event)).to eq nil
    end

    it 'processes an event we know how to handle' do
      expect_any_instance_of(StripeHooks::Account).to receive(:process)
      event = OpenStruct.new(type: 'account.application.deauthorized')
      StripeHooks.process_event(event)
    end
  end
end
