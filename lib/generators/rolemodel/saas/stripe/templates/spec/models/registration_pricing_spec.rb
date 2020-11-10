# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RegistrationPricing, type: :model do
  let(:event) { create(:event_with_course, :with_tags) }
  let!(:info) { create(:event_registration_info, event: event) }
  let(:paid_order) { create(:registration_order, event: event) }
  let(:unpaid_order) { create(:registration_order, :unpaid, event: event) }
  let(:participant_item_1) { create(:contestant_item, registration_order: paid_order, tags: [event.tag_config['classes'].first, event.tag_config['gender'].first].join(' ')) }
  let(:participant_item_2) { create(:contestant_item, registration_order: paid_order, tags: [event.tag_config['classes'].last, event.tag_config['gender'].last].join(' ')) }
  let(:ticket) { create(:ticket, event: event, name: 'Spectator Ticket', price: 10.66) }
  let(:spectators_1_line_item) { create(:ticket_item, ticket: ticket, quantity: 1, registration_order: paid_order) }
  let(:spectators_4_line_item) { create(:ticket_item, ticket: ticket, quantity: 4, registration_order: paid_order) }

  context 'single participant' do
    let(:pricing) { RegistrationPricing.new(participant_item_1.registration_order) }

    it 'has a base_price equal to the participants registration_price' do
      expect(pricing.base_price).to eq participant_item_1.registration_price.round(2)
    end

    it 'has convenience fees which include only the expected percentage plus participant ticket fee' do
      expect(pricing.total_convenience_fees).to eq((RegistrationPricing::PARTICIPANT_CONVENIENCE_FEE_PERCENTAGE * participant_item_1.registration_price + RegistrationPricing::FIXED_CONVENIENCE_FEE_PER_PARTICIPANT).round(2))
    end

    it 'has a total_price of base_price + convenience fees' do
      expect(pricing.total_price).to eq((pricing.base_price + pricing.total_convenience_fees).round(2))
    end
  end

  context '#process' do
    let(:payment_source) { PaymentSource.new(unpaid_order.user, nil) }
    let(:pricing) { RegistrationPricing.new(unpaid_order, payment_source) }

    context 'total_price = 0' do
      it 'sets the purchase total' do
        expect(unpaid_order.purchase_total).to be_nil
        pricing.process
        expect(unpaid_order.purchase_total).to eq 0
      end
    end

    context 'total_price > 0' do
      let(:volunteer_ticket) { create(:ticket, event: event, name: 'Volunteer Ticket', price: 0) }
      let(:athlete_tags) { [event.tag_config['classes'].first, event.tag_config['gender'].first].join(' ') }
      let!(:athlete_item) { create(:contestant_item, registration_order: unpaid_order, tags: athlete_tags) }
      let!(:volunteer_item) { create(:ticket_item, ticket: volunteer_ticket, quantity: 1, registration_order: unpaid_order) }
      let(:balance_transaction) do
        build(:mock_stripe_balance, fee_details: [OpenStruct.new(type: 'stripe_fee', amount: 399)])
      end

      before do
        allow_any_instance_of(Organization).to receive(:verified_stripe_customer_id).and_return 'cus_1'
        allow(Stripe::Customer).to receive(:create_source).and_return(build(:mock_stripe_source))
        allow(Stripe::Customer).to receive(:list).and_return([])
        allow(Stripe::Invoice).to receive(:create).and_return build(:mock_stripe_invoice)
        # TODO: Move this call to customer to ... something?
        allow(Stripe::Customer).to receive(:retrieve).and_return(build(:mock_stripe_customer))
        allow(Stripe::Source).to receive(:create).and_return(build(:mock_stripe_source))
        allow(Stripe::Charge).to receive(:retrieve).and_return(build(:mock_stripe_charge))
        allow(Stripe::BalanceTransaction).to receive(:retrieve).and_return(balance_transaction)
      end

      it 'includes sending free line items to Stripe' do
        # 4 times:
        # 1 for an empty item to start the invoice, which gets deleted later
        # 3 for the actual items we need processed
        expect(Stripe::InvoiceItem).to receive(:create).exactly(4).times.and_return(build(:mock_stripe_invoice_item))
        pricing.process
      end

      it 'includes sending cost items to Stripe' do
        allow(Stripe::InvoiceItem).to receive(:create)
        pricing.process
        expect(Stripe::InvoiceItem).to have_received(:create).with(
          hash_including(description: "#{athlete_item.name}, #{athlete_tags}"),
          stripe_account: anything
        )
      end

      it 'sets the purchase total' do
        allow(Stripe::InvoiceItem).to receive(:create)
        pricing.process
        expect(unpaid_order.purchase_total).to be > 0
      end

      it 'retrieves the fees from Stripe' do
        allow(Stripe::InvoiceItem).to receive(:create)
        pricing.process
        expect(unpaid_order.processing_fees).to eq 3.99
      end
    end
  end

  context 'single spectator' do
    let(:pricing) { RegistrationPricing.new(spectators_1_line_item.registration_order) }

    it 'has a base_price equal to the spectator ticket price' do
      expect(pricing.base_price).to eq ticket.price.round(2)
    end

    it 'has convenience fees which include only the expected percentage plus participant ticket fee' do
      expect(pricing.total_convenience_fees).to eq((RegistrationPricing::SIMPLE_TICKET_CONVENIENCE_FEE_PERCENTAGE * ticket.price + RegistrationPricing::FIXED_CONVENIENCE_FEE_PER_SIMPLE_TICKET).round(2))
    end

    it 'has a total_price of base_price + convenience fees' do
      expect(pricing.total_price).to eq((pricing.base_price + pricing.total_convenience_fees).round(2))
    end
  end

  context 'free spectator' do
    let(:free_ticket) { create(:ticket, event: event, name: 'Free Spectator Ticket', price: 0.00) }
    let(:free_spectator_line_item) { create(:ticket_item, ticket: free_ticket, quantity: 1, registration_order: paid_order) }
    let(:pricing) { RegistrationPricing.new(free_spectator_line_item.registration_order) }

    it 'has a base_price equal to the spectator ticket price' do
      expect(pricing.base_price).to eq 0.00
    end

    it 'has no convenience fees which include only the expected percentage plus participant ticket fee' do
      expect(pricing.total_convenience_fees).to eq(0.00)
    end

    it 'has a total_price of base_price + convenience fees' do
      expect(pricing.total_price).to eq(0.00)
    end
  end

  context 'combined' do
    let!(:line_items) { [participant_item_1, participant_item_2, spectators_4_line_item] }
    let(:pricing) { RegistrationPricing.new(paid_order) }

    it 'has a base_price equal to the spectator ticket price' do
      expected_base_price = spectators_4_line_item.quantity * ticket.price + participant_item_1.unit_price + participant_item_2.unit_price
      expect(pricing.base_price).to eq expected_base_price.round(2)
    end

    it 'has convenience fees which include only the expected percentage plus participant ticket fee' do
      expected_spectator_fees = (spectators_4_line_item.quantity * (RegistrationPricing::SIMPLE_TICKET_CONVENIENCE_FEE_PERCENTAGE * ticket.price + RegistrationPricing::FIXED_CONVENIENCE_FEE_PER_SIMPLE_TICKET)).round(2)
      expected_participant_fees = ((RegistrationPricing::PARTICIPANT_CONVENIENCE_FEE_PERCENTAGE * (participant_item_1.unit_price + participant_item_2.unit_price) + 2 * RegistrationPricing::FIXED_CONVENIENCE_FEE_PER_PARTICIPANT))
      expect(pricing.total_convenience_fees).to eq(expected_spectator_fees + expected_participant_fees)
    end

    it 'has a total_price of base_price + convenience fees' do
      expect(pricing.total_price).to eq((pricing.base_price + pricing.total_convenience_fees).round(2))
    end
  end
end
