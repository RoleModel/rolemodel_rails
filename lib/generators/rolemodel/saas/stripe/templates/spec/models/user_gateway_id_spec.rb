# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserGatewayId, type: :model do
  let(:user) { build(:user) }

  subject(:model) do
    described_class.new(
      user: user,
      connect_account: connect_account,
      stripe_customer_id: customer_id
    )
  end

  describe '#verified_stripe_customer_id' do
    ['acct_rocksolidwarrior', nil].each do |connect_account|
      context "#{connect_account.present? ? 'with' : 'without'} Connect account" do
        let(:connect_account) { connect_account }

        context 'with existing customer_id' do
          let(:customer_id) { 'cus_1' }

          it 'returns the current customer_id if customer exists' do
            expect(Stripe::Customer)
              .to receive(:retrieve)
              .and_return(build(:mock_stripe_customer, id: customer_id))

            expect(model.verified_stripe_customer_id).to eq customer_id
          end

          it 'creates a new Stripe customer if customer was deleted' do
            expect(Stripe::Customer)
              .to receive(:retrieve)
              .with(customer_id, stripe_account: connect_account)
              .and_raise(Stripe::StripeError, 'Customer not found!')
            expect(Stripe::Customer)
              .to receive(:list)
              .with({ email: user.email }, stripe_account: connect_account)
              .and_return([])
            expect(Stripe::Customer)
              .to receive(:create)
              .and_return(build(:mock_stripe_customer, id: 'cus_2'))

            expect(model.verified_stripe_customer_id).to eq 'cus_2'
          end
        end

        context 'without existing customer_id' do
          let(:customer_id) { nil }

          it 'returns a matching customer_id by email' do
            expect(Stripe::Customer)
              .to receive(:retrieve)
              .with(customer_id, stripe_account: connect_account)
              .and_raise(Stripe::StripeError, 'Customer not found!')
            expect(Stripe::Customer)
              .to receive(:list)
              .with({ email: user.email }, stripe_account: connect_account)
              .and_return([build(:mock_stripe_customer, id: 'cus_2')])

            expect(model.verified_stripe_customer_id).to eq 'cus_2'
          end

          it 'creates a Stripe customer if no matches by email are found' do
            expect(Stripe::Customer)
              .to receive(:retrieve)
              .with(customer_id, stripe_account: connect_account)
              .and_raise(Stripe::StripeError, 'Customer not found!')
            expect(Stripe::Customer)
              .to receive(:list)
              .with({ email: user.email }, stripe_account: connect_account)
              .and_return([])
            expect(Stripe::Customer)
              .to receive(:create)
              .and_return(build(:mock_stripe_customer, id: 'cus_2'))

            expect(model.verified_stripe_customer_id).to eq 'cus_2'
          end
        end
      end
    end
  end
end
