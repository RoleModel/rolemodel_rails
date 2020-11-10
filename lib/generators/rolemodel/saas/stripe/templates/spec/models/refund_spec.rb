# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Refund, type: :model do
  let(:order) { create(:registration_order) }
  let(:items) do
    create_list(
      :contestant_item, 3, :with_tags,
      registration_order: order,
      recorded_price: 10.99
    )
  end

  subject(:refund) { described_class.create(registration_order: order, refunded_by: build(:user)) }

  describe 'scopes' do
    let(:refund) { described_class.create(registration_order: order, registration_items: items, refunded_by: build(:user)) }

    describe '.for_item' do
      it 'returns a refund with a registration item that matches the passed id' do
        expect(described_class.for_item(items.first.id)).to contain_exactly(refund)
      end
    end
  end

  describe '#registration_items' do
    it 'can be associated to many registration items' do
      expect(refund.registration_items.count).to eq 0
      refund.update(registration_items: [items.first])
      expect(refund.registration_items.count).to eq 1
      expect(refund.reload.registration_items.first).to eq items.first
    end
  end

  describe '#requested_refund_amount' do
    it 'returns the summed recorded_price of any assigned items' do
      refund.update!(registration_items: items.first)
      refunded_amount = refund.requested_refund_amount()
      expect(refunded_amount).to eq items.first.recorded_price
    end
  end

  describe '#request_refund!' do
    it 'uses cents to describe price amount provided to payment gateway' do
      refund.update(registration_items: items.first)
      allow(Stripe::Invoice).to receive(:retrieve).and_return(build(:mock_stripe_invoice))
      allow(Stripe::Refund).to receive(:create).and_return(build(:mock_stripe_refund))
      refund.request_refund!

      expect(Stripe::Refund).to have_received(:create).with(
        hash_including(amount: 1099),
        stripe_account: anything
      )
    end

    context 'entire order' do
      let(:base_price) { items.sum(&:recorded_price) }
      let(:convenience_fees) { 4 }
      let(:total) { convenience_fees + base_price }

      before(:each) do
        order.update(
          convenience_fees: convenience_fees,
          base_price: base_price,
          purchase_total: total
        )
        refund.update(registration_items: items)
      end

      # See workflow on Stripe: https://stripe.com/docs/billing/invoices/workflow
      describe 'registration order status is draft' do
        it 'deletes the draft invoice' do
          allow(Stripe::Invoice).to receive(:retrieve).and_return(build(:mock_stripe_invoice, :draft))
          allow(Stripe::Invoice).to receive(:delete).and_return(build(:mock_stripe_invoice, :deleted))

          refund.request_refund!

          expect(Stripe::Invoice).to have_received(:delete).once
          expect(order.refunded_convenience_fees).to eq convenience_fees
        end
      end

      describe 'registration order status is open' do
        it 'voids the open invoice' do
          allow(Stripe::Invoice).to receive(:retrieve).and_return(build(:mock_stripe_invoice, :pending))
          allow(Stripe::Invoice).to receive(:void_invoice).and_return(build(:mock_stripe_invoice, :voided))

          refund.request_refund!

          expect(Stripe::Invoice).to have_received(:void_invoice).once
          expect(order.refunded_convenience_fees).to eq convenience_fees
        end
      end

      describe 'registration order status is paid' do
        it 'refunds the paid invoice without convenience fees' do
          allow(Stripe::Invoice).to receive(:retrieve).and_return(build(:mock_stripe_invoice))
          allow(Stripe::Refund).to receive(:create).and_return(build(:mock_stripe_refund))

          refund.request_refund!

          expect(Stripe::Refund).to have_received(:create).once
          expect(order.refunded_convenience_fees).to eq 0
        end

        it 'refunds the paid invoice price, plus convenience fees if requested' do
          allow(Stripe::Invoice).to receive(:retrieve).and_return(build(:mock_stripe_invoice, total: total))
          allow(Stripe::Refund).to receive(:create).and_return(build(:mock_stripe_refund, amount: total))

          refund.request_refund!(true)

          expect(Stripe::Refund).to have_received(:create).once
          expect(order.refunded_convenience_fees).to eq convenience_fees
        end
      end
    end
  end

  describe 'private methods' do
    describe '#all_items_selected?' do
      it 'returns false if not refunding all items on the order' do
        refund = described_class.create(registration_order: order, registration_items: [items.first])
        expect(refund.send(:all_items_selected?)).to be_falsey
      end

      it 'returns true if refunding all items on the order' do
        expect(refund.send(:all_items_selected?)).to be_truthy
      end
    end
  end
end
