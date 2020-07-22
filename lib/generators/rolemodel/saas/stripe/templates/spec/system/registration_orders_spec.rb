# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Registration Orders', :js do
  let(:organization) { create(:subscribed_organization) }
  let(:user) { create(:user, :org_admin, organization: organization) }

  let(:registered_event) { create(:event, organization: organization, start_date: 3.days.from_now) }
  let!(:non_registered_event) { create(:event, organization: organization, start_date: 3.days.from_now) }
  let!(:registration_order_paid) { create(:registration_order, event: registered_event, user: user, convenience_fees: 6) }
  let!(:other_registration_order_paid) { create(:registration_order, event: registered_event, user: user, convenience_fees: 6)}
  let!(:registration_order_unpaid) { create(:registration_order, :unpaid, user: user) }

  before do
    sign_in user
  end

  describe 'viewing list of receipts' do
    def order_event_name(order)
      Event.find(order.event_id).name
    end

    before do
      visit organization_path(organization)
    end

    it 'displays a list of paid registration orders' do
      expect(page).to have_content order_event_name(registration_order_paid)
    end

    it 'excludes unpaid registration orders' do
      expect(page).not_to have_content order_event_name(registration_order_unpaid)
    end
  end

  describe 'viewing the refund event button' do
    before do
      visit registration_orders_event_path(registered_event)
    end

    def order_event_name(order)
      Event.find(order.event_id).name
    end

    context 'when there are no registration orders' do
      before do
        visit registration_orders_event_path(non_registered_event)
      end

      it 'does not display the refund event button' do
        expect(page).to_not have_content("[data-test-id='refund-all-button']")
      end
    end

    context 'when there are registration orders' do

      before do
        visit registration_orders_event_path(registered_event)
      end

      it 'displays the refund event button' do
        refund_button = find("[data-test-id='refund-all-button']")
        expect(page).to have_content(refund_button.text)
      end
    end
  end

  describe 'refunding an order', js: false do
    let!(:registration_order_unpaid) { create(:registration_order, :unpaid, event: registered_event, user: user)}
    let!(:registration_order_paid) { create(:registration_order, event: registered_event, user: user, base_price: 60, convenience_fees: 4) }
    let!(:contestant_item) { create(:contestant_item, :with_tags, registration_order: registration_order_paid, recorded_price: 30, convenience_fees: 2, gym_revenue: 29.25) }
    let!(:ticket_item) { create(:ticket_item, registration_order: registration_order_paid, quantity: 2, recorded_price: 30, convenience_fees: 2, gym_revenue: 29.25) }

    let(:settled_invoice) { build(:mock_stripe_invoice) }
    let(:pending_invoice) { build(:mock_stripe_invoice, :pending) }
    let(:voided_invoice) { build(:mock_stripe_invoice, :voided) }
    let(:successful_refund_response) { build(:mock_stripe_refund) }

    describe 'payment pending settlement' do
      before do
        allow(Stripe::Invoice).to receive(:retrieve).and_return(pending_invoice)
        expect(Stripe::Invoice).to receive(:void_invoice).and_return(voided_invoice)
        visit edit_registration_order_path(registration_order_paid)
      end

      it 'can void the entire transaction' do
        expect(page).to have_content("Order ##{registration_order_paid.padded_id}")
        expect(page).to have_content('Athletes: 1')
        expect(page).to have_content('Spectators: 2')

        all('label', text: 'Refund').each(&:click) # Check both Refund boxes
        click_on 'Refund checked items'

        expect(page).to have_content('Athletes: 0')
        expect(page).to have_content('Spectators: 0')
        expect(page).to have_content('Your share: $0.00')
        expect(page).to have_content('$30.00 Refunded', count: 2)
      end
    end

    describe 'payment settled' do
      before do
        expect(Stripe::Invoice).to receive(:retrieve).and_return(settled_invoice)
        expect(Stripe::Refund).to receive(:create).and_return(successful_refund_response)
        visit edit_registration_order_path(registration_order_paid)

        expect(page).to have_content('Athletes: 1')
        expect(page).to have_content('Spectators: 2')
      end

      it 'can void the entire transaction' do
        all('label', text: 'Refund').each(&:click) # Check both Refund boxes
        click_on 'Refund checked items'
        expect(page).to have_content('Athletes: 0')
        expect(page).to have_content('Spectators: 0')
        expect(page).to have_content('Your share: $0.00')
        expect(page).to have_content('$30.00 Refunded', count: 2)
      end

      it 'can refund some of the items' do
        find(data_test("refund-item-#{contestant_item.id}")).click
        click_on 'Refund checked items'

        expect(page).to have_content('Athletes: 0')
        expect(page).to have_content('Spectators: 2')
        expect(page).to have_content('Your share: $29.25')
        expect(page).to have_content('$30.00 Refunded')
      end
    end

    describe 'refund event', js: true do
      it 'displays refunded convenience fees' do

        allow(Stripe::Invoice).to receive(:retrieve).and_return(settled_invoice)
        allow(Stripe::Refund).to receive(:create).and_return(successful_refund_response)
        visit registration_orders_event_path(registered_event)

        refund_button = find("[data-test-id='refund-all-button']")
        refund_button.click
        page.driver.browser.switch_to.alert.accept
        expect(page).to have_text("All Registration Orders successfully refunded!")
      end
    end

    describe 'failed transaction' do
      before do
        expect(Stripe::Invoice).to receive(:retrieve).and_return(settled_invoice)
        expect(Stripe::Refund).to receive(:create).and_raise(Stripe::StripeError, "Invalid positive integer")
        visit edit_registration_order_path(registration_order_paid)
      end

      it 'shows an error message' do
        click_on 'Refund checked items' # Submit without any items

        expect(page).to have_content('Invalid positive integer')
        expect(page).to have_content('Athletes: 1')
        expect(page).to have_content('Spectators: 2')
      end
    end

    describe '5% charge override' do
      before do
        expect(Stripe::Invoice).to receive(:retrieve).and_return(settled_invoice)
        expect(Stripe::Refund).to receive(:create).and_return(successful_refund_response)
        visit edit_registration_order_path(registration_order_paid)
      end
    end

    describe 'mixed ticket prices' do
      let!(:ticket_item) { create(:ticket_item, registration_order: registration_order_paid, quantity: 2, recorded_price: 0, convenience_fees: 0, gym_revenue: 0) }

      before do
        expect(Stripe::Invoice).to receive(:retrieve).and_return(settled_invoice)
        expect(Stripe::Refund).to receive(:create).and_return(successful_refund_response)
        visit edit_registration_order_path(registration_order_paid)
      end

      it 'allows you to refund an order with free tickets and paid tickets' do
        expect(page).to have_content("Order ##{registration_order_paid.padded_id}")
        expect(page).to have_content('Athletes: 1')
        expect(page).to have_content('Spectators: 2')

        all('label', text: 'Refund').each(&:click) # Check both Refund boxes
        click_on 'Refund checked items'

        expect(page).to have_content('Athletes: 0')
        expect(page).to have_content('Spectators: 0')
        expect(page).to have_content('Your share: $0.00')
        expect(page).to have_content('$30.00 Refunded', count: 1)
      end
    end
  end

  describe 'viewing a receipt' do
    context 'without items' do
      before do
        visit registration_order_path(registration_order_paid)
      end

      it 'displays the event name' do
        expect(page).to have_content registered_event.name
      end

      it 'displays total price' do
        expect(page).to have_content registration_order_paid.purchase_total
      end
    end

    context 'with items' do
      let(:ticket) { create(:ticket, event: registered_event, name: 'My ticket', price: '5.31') }
      let!(:contestant_item) { create(:contestant_item, :with_tags, :with_price, registration_order: registration_order_paid) }
      let!(:ticket_item) { create(:ticket_item, :with_price, ticket: ticket, registration_order: registration_order_paid, quantity: 4) }

      before do
        visit registration_order_path(registration_order_paid)
      end

      it 'displays athletes as line items' do
        within 'ul' do
          expect(page).to have_content "Contestant: #{contestant_item.athlete.name}"
          expect(page).to have_content contestant_item.recorded_price
        end
      end

      it 'displays tickets as line items' do
        within 'ul' do
          expect(page).to have_content "Ticket: #{ticket_item.name}"
          expect(page).to have_content ticket_item.recorded_price
        end
      end

      it 'displays convenience fees' do
        within 'ul' do
          expect(page).to have_content registration_order_paid.convenience_fees
        end
      end
    end
  end
end
