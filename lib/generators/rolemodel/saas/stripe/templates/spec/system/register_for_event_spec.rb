# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Register for event', :js, :vcr do
  let(:organization) { create(:subscribed_organization) }
  let(:user) { create(:user, :with_stripe_customer, organization: organization) }
  let(:pro_tag) { 'pro' }
  let(:gender_tag) { 'female' }
  let!(:event) do
    create(
      :event,
      name: 'Enduro',
      organization: organization,
      start_date: 20.days.from_now,
      tag_config: {
        classes: [pro_tag, 'amateur'],
        gender: ['male', gender_tag]
      }
    )
  end
  let!(:course) { create :course, event: event }
  let!(:athlete1) { create :athlete, name: 'Jenna', user: user }
  let!(:athlete2) { create :athlete, name: 'John', user: user }
  let!(:athlete3) { create :athlete, name: 'Joey', user: user }

  before do
    sign_in user
  end

  context 'registrable event (non-virtual)' do
    before do
      event.update(virtual: false, enable_registration: true)
      EventRegistrationInfo.create(event: event, price: 60)
    end

    it 'directs to the correct registration page' do
      visit virtual_events_path
      click_on event.name
      click_on 'Register'

      expect(page).to have_content('Athletes')
      expect(page).to have_current_path(contestants_registration_event_path(event))
    end

    it 'show registration closed if any registration orders exist registration turned off' do
      event.update(enable_registration: false)
      create(:registration_order, event: event)
      visit show_event_path(event)
      expect(page).to have_content 'Registration is now closed'
    end

    context 'when the user forgets to select a tag' do
      it 'redirects to the register page' do
        visit contestants_registration_event_path(event)

        within("#athlete_#{athlete1.id}") do
          click_button 'Add To Cart'
        end

        within(data_test('tags-modal')) do
          click_button 'Add To Cart'
        end

        expect(page).to have_content "Please select groups for #{athlete1.name}"
      end
    end

    describe 'emails' do
      it 'sends an email when registered' do
        paid_order = create :registration_order, :unpaid, event: event, user: user
        create :contestant_item, :with_tags, registration_order: paid_order, athlete: athlete1

        visit(checkout_event_path(event))
        fill_in_card_form
        expect {
          find('label[for="registration_agreed_to_terms"]').click
          click_on 'Confirm Payment'
          expect(page).to have_current_path(confirmation_registration_orders_path(paid_order.id))
        }.to have_enqueued_job.on_queue('mailers')

        click_on 'click here'
        expect(page).to have_content 'You have successfully signed up for the following event:'
      end
    end

    it 'allows a new athlete to be registered for the event' do
      visit contestants_registration_event_path(event)

      # Check that new athlete doesn't exist
      [athlete1, athlete2, athlete3].each do |athlete|
        expect(page).to have_content(athlete.name)
      end
      expect(page).to have_no_content('John Smith')

      # Add new athlete
      click_on 'Add Athlete'
      enter_athlete_info
      click_on 'Create Athlete'

      # New athlete is displayed
      expect(page).to have_current_path(contestants_registration_event_path(event.id))
      expect(page).to have_content('John Smith')
      expect(page).to have_content('J Smith')
    end

    it 'allows an existing athlete to be registered for the event' do
      create :athlete, name: 'John Smith', birthdate: Date.new(2000, 1, 1), gender: :male
      visit contestants_registration_event_path(event)

      # Check that new athlete doesn't exist
      [athlete1, athlete2, athlete3].each do |athlete|
        expect(page).to have_content(athlete.name)
      end
      expect(page).to have_no_content('John Smith')

      click_on 'Add Athlete'
      enter_athlete_info(use_suggestion: true)
      expect { click_on 'Yes' }.not_to change(Athlete, :count)
    end

    describe 'continuing to checkout' do
      let(:unpaid_order) { create(:registration_order, :unpaid, event: event, user: user) }
      let!(:unpaid_item1) { create(:contestant_item, :with_tags, registration_order: unpaid_order, athlete: athlete1) }
      let!(:unpaid_item2) { create(:contestant_item, registration_order: unpaid_order, athlete: athlete2, tags: '11-13 female pro') }

      it 'displays the necessary content' do
        visit contestants_registration_event_path(event)
        click_on 'Checkout'

        # Ensure registered athletes and costs are on the page
        within '.event-contestant__registrant-wrapper' do
          expect(page).to have_content(unpaid_item1.athlete.name)
          expect(page).to have_content(unpaid_item1.registration_price)

          expect(page).to have_content(unpaid_item2.athlete.name)
          expect(page).to have_content(unpaid_item2.registration_price)
        end

        # Ensure totals are displayed
        within '.registration-fees' do
          price = RegistrationPricing.new(unpaid_order)
          expect(page).to have_content(price.base_price)
          expect(page).to have_content(price.total_convenience_fees)
          expect(page).to have_content(price.total_price)
        end

        # Ensure purchase button is visible
        expect(page).to have_button('Confirm Payment', disabled: true)
      end

      it 'enables Confirm button when agreed to terms is checked' do
        visit contestants_registration_event_path(event)
        click_on 'Checkout'

        expect(page).to have_button('Confirm Payment', disabled: true)
        find('label[for="registration_agreed_to_terms"]').click
        expect(page).to have_button('Confirm Payment', disabled: false)
      end

      context 'when a promo code is applied' do
        let!(:promotional_code) { create :promotional_code, event_registration_info: event.event_registration_info }

        context 'when valid' do
          it 'notifies the user that it was successful' do
            visit contestants_registration_event_path(event)
            click_on 'Checkout'

            fill_in 'promo_code', with: 'faith'
            click_on 'Apply'

            expect(page).to have_content('Applied promo code faith')
          end
        end

        context 'when invalid' do
          it 'notifies the user that it could not be found' do
            visit contestants_registration_event_path(event)
            click_on 'Checkout'

            fill_in 'promo_code', with: 'works'
            click_on 'Apply'

            expect(page).to have_content('Could not find promo code works')
          end
        end
      end
    end

    describe 'user has no athletes' do
      before do
        user.athletes.delete_all
      end

      it 'displays the blank state and does not display the checkout button' do
        visit contestants_registration_event_path(event)
        expect(page).to_not have_content('Checkout')
        expect(page).to have_content('to register them to compete in this event.')
      end

      context 'clicking on the blank state link' do
        it 'redirects to the new athlete form' do
          visit contestants_registration_event_path(event)
          click_on 'Add an Athlete'
          expect(page).to have_current_path(new_athlete_path, ignore_query: true)
        end
      end

      context 'user has tickets configured' do
        let!(:ticket) { create(:ticket, event: event, name: 'Spectator Tickets', price: 10.66) }

        it 'displays the blank state and also displays the cart' do
          visit contestants_registration_event_path(event)
          expect(page).to have_content('to register them to compete in this event.')

          expect(page).to have_content('Cart')
          expect(page).to have_content(ticket.name)
          expect(page).to have_content(ticket.price)
        end
      end
    end

    describe 'continuing to confirmation' do
      let(:registration_order) { create(:registration_order, :unpaid, event: event, user: user) }
      let!(:registration_item) { create(:contestant_item, :with_tags, registration_order: registration_order, athlete: athlete1) }

      context 'with subscription' do
        let(:user) { create(:user, :org_admin, :with_stripe_customer, organization: organization) }

        it 'displays message' do
          visit contestants_registration_event_path(event)
          click_on 'Checkout'
          fill_in_card_form
          find('label[for="registration_agreed_to_terms"]').click
          click_on 'Confirm Payment'

          expect(page).to have_content('Successfully registered')
          expect(page).to have_content('You will receive an email with a receipt confirming your registration')

          expect(page).to have_no_content('Upgrade to participant plan')
        end
      end

      context 'without subscription' do
        let(:user) { create(:user, :org_admin, :with_stripe_customer) }

        it 'displays message and upsell' do
          visit contestants_registration_event_path(event)
          click_on 'Checkout'
          fill_in_card_form
          find('label[for="registration_agreed_to_terms"]').click
          click_on 'Confirm Payment'

          find('.confirmation__cta-button').click
          expect(page).to have_content('Participant Yearly')
        end
      end
    end

    describe 'user has existing registered athletes' do
      let(:other_event) do
        create(
          :event,
          name: 'Unrelated to Registration',
          organization: organization,
          virtual: true,
          start_date: 20.days.from_now,
          tag_config: {
            classes: [pro_tag, 'amateur'],
            gender: ['male', gender_tag]
          }
        )
      end
      let(:unpaid_order) { create(:registration_order, :unpaid, event: event, user: user) }
      let!(:unpaid_item) { create(:contestant_item, registration_order: unpaid_order, athlete: athlete1, tags: '11-13 female pro') }

      let(:paid_order) { create(:registration_order, event: event, user: user) }
      let!(:paid_item) { create(:contestant_item, registration_order: paid_order, athlete: athlete2, tags: '11-13 female pro') }

      let(:other_paid_order) { create(:registration_order, event: other_event, user: user) }
      let!(:other_paid_item) { create(:contestant_item, :with_price, registration_order: other_paid_order, athlete: athlete3, tags: '11-13 female pro') }

      it 'shows athletes in appropriate states' do
        visit contestants_registration_event_path(event)
        within("#athlete_#{athlete1.id}") do
          expect(page).to have_content(athlete1.name)
          expect(page).to have_button('Remove')
        end
        within("#athlete_#{athlete2.id}") do
          expect(page).to have_content(athlete2.name)
          expect(page).to have_content('Registered')
        end
        within("#athlete_#{athlete3.id}") do
          expect(page).to have_content(athlete3.name)
          expect(page).to have_button('Add To Cart')
        end
      end
    end

    describe 'cancelling the creation of an athlete' do
      it 'redirects back to the contestant registration' do
        visit contestants_registration_event_path(event)

        click_on 'Add Athlete'
        enter_athlete_info
        click_on 'Cancel'

        expect(page).to have_current_path(contestants_registration_event_path(event.id))
        expect(page).to have_no_content('John Smith')
      end
    end

    describe 'spectator tickets' do
      let!(:unpaid_order) { create(:registration_order, :unpaid, event: event, user: user) }
      let!(:ticket) { create(:ticket, name: 'Spectator Ticket', price: 10.66, event: event) }

      context 'with existing items' do
        let!(:unpaid_item1) { create(:contestant_item, :with_tags, registration_order: unpaid_order, athlete: athlete1) }
        let!(:unpaid_item2) { create(:ticket_item, quantity: 5, registration_order: unpaid_order, ticket: ticket) }

        it 'displays the necessary content' do
          visit contestants_registration_event_path(event)
          click_on 'Checkout'

          # Ensure registered athletes and costs are on the page
          within '.event-contestant__registrant-wrapper' do
            expect(page).to have_content(unpaid_item1.athlete.name)
            expect(page).to have_content(unpaid_item1.registration_price)

            expect(page).to have_content(unpaid_item2.description)
            expect(page).to have_content(unpaid_item2.registration_price)
          end

          # Ensure totals are displayed
          within '.registration-fees' do
            price = RegistrationPricing.new(unpaid_order)
            expect(page).to have_content(price.base_price)
            expect(page).to have_content(price.total_convenience_fees)
            expect(page).to have_content(price.total_price)
          end

          # Ensure purchase button is visible
          expect(page).to have_button('Confirm Payment', disabled: true)
        end
      end

      context 'without existing items' do
        let(:initial_quantity) { 5 }
        let(:secondary_quantity) { 10 }

        it 'Selected quantity show on checkout page' do
          visit contestants_registration_event_path(event)

          # Select quantity of tickets
          fill_in 'quantity', with: initial_quantity

          click_on 'Checkout'

          item = unpaid_order.registration_items.first

          # Ensure registered athletes and costs are on the page
          within '.event-contestant__registrant-wrapper' do
            expect(item.description).to include(initial_quantity.to_s)
            expect(page).to have_content(item.description)
            expect(page).to have_content(item.registration_price)
          end

          click_on 'Back to Athletes'

          fill_in 'quantity', with: secondary_quantity

          click_on 'Checkout'

          item = unpaid_order.registration_items.first

          # Ensure registered athletes and costs are on the page
          within '.event-contestant__registrant-wrapper' do
            expect(item.description).to include(secondary_quantity.to_s)
            expect(page).to have_content(item.description)
            expect(page).to have_content(item.registration_price)
          end
        end

        context 'other order with ticket' do
          let!(:other_order) { create(:registration_order, :unpaid, event: event) }
          let!(:other_item) { create(:ticket_item, ticket: ticket, quantity: 2, registration_order: other_order, recorded_price: 21.32) }

          it 'displays the blank state and also displays the cart' do
            visit contestants_registration_event_path(event)
            expect(find_field('quantity').value).to eq '0'
            expect(page).to have_content('Your Cart is empty.')
          end
        end

        context 'already paid order with ticket' do
          let!(:other_order) { create(:registration_order, event: event) }
          let!(:other_item) { create(:ticket_item, ticket: ticket, quantity: 2, registration_order: other_order, recorded_price: 21.32) }

          it 'displays the blank state and also displays the cart' do
            visit contestants_registration_event_path(event)
            expect(find_field('quantity').value).to eq '0'
            expect(page).to have_content('Your Cart is empty.')
          end
        end
      end
    end

    context 'when the event is sanctioned for an event that has memberships' do
      let!(:athlete1) { create :athlete, :with_additional_attributes, name: 'Jenna', user: user }
      let!(:season) { create :season, :for_unaa_league }
      let!(:sanction) do
        create :sanction,
        season: season,
        rule_set: RuleSet::UNAA,
        run_scoring_strategy_name: UNAAQualifierRecap
      end

      before do
        event.update(sanction: sanction, tag_config: season.tag_config)
      end

      let!(:course) { create :course, event: event, sanction: sanction }

      it 'allows users to add league memberships' do
        event.update(default_rule_set: RuleSet::UNAA)
        visit contestants_registration_event_path(event)

        within(data_test("athlete-#{athlete1.id}")) do
          click_on 'Add To Cart' # opens tags selection dialog
        end

        within(data_test('tags-modal')) do
          click_on 'Add To Cart' # actually adds them to the cart
        end

        click_on "Add #{season.league.name} Membership"

        find(data_test('address-autocomplete')).set '570 Johnson Dr Aspen, CO 81611, USA'

        click_on 'Save Address'

        within(data_test('cart')) do
          expect(page).to have_content "Contestant: #{athlete1.name}"
          expect(page).to have_content "Membership: #{athlete1.name}"
          expect(page).to_not have_content "FIX ATHLETE" # ensure the athlete is valid
        end

        click_on 'Checkout'

        # Ensure registered athletes and costs are on the page
        within '.event-contestant__registrant-wrapper' do
          item = RegistrationOrder.last.contestant_items.first
          expect(page).to have_content "Contestant: #{athlete1.name}"
          expect(page).to have_content(item.registration_price)

          expect(page).to have_content "Membership: #{athlete1.name}"
          expect(page).to have_content(season.membership_price)
        end

        fill_in_card_form
        find('label[for="registration_agreed_to_terms"]').click
        click_on 'Confirm Payment'

        expect(page).to have_content('receipt confirming your registration')
        expect(page).to have_content('receipt confirming your membership')

        expect(user.registration_orders.count).to eq 2
      end

      context 'when the league has discounts for members' do
        let!(:non_member_athlete) { create :athlete, :with_additional_attributes, name: 'Amber', user: user }
        let(:member_athlete) { create :athlete, :with_additional_attributes, name: 'Kaila', user: user }
        let!(:league_membership) { create :league_membership, athlete: member_athlete, season: season }

        before do
          event.update(default_rule_set: 'RuleSet::UNAA')
          event.event_registration_info.update(league_member_discount: true)
          athlete1.update(address: '570 Johnson Dr Aspen, CO 81611, USA')
        end

        it 'takes that discount off the contestant price for current and pending members' do
          visit contestants_registration_event_path(event)

          add_athlete_to_cart(athlete1)
          add_athlete_to_cart(member_athlete)
          add_athlete_to_cart(non_member_athlete)

          within(data_test("athlete-#{athlete1.id}")) do
            click_on "Add #{season.league.name} Membership"
          end

          within(data_test('cart')) do
            expect(page).to have_content "Contestant: #{athlete1.name}"
            expect(page).to have_content "Membership: #{athlete1.name}"
            expect(page).to have_content "Contestant: #{member_athlete.name}"
            expect(page).to have_content "Contestant: #{non_member_athlete.name}"
          end

          click_on 'Checkout'

          # Ensure registered athletes and costs are on the page
          within '.event-contestant__registrant-wrapper' do
            expect_correct_price_for_contestant(athlete1, event, discount: true)
            expect_correct_price_for_contestant(member_athlete, event, discount: true)
            expect_correct_price_for_contestant(non_member_athlete, event, discount: false)

            expect(page).to have_content "Membership: #{athlete1.name}"
            expect(page).to have_content(season.membership_price)
          end


          fill_in_card_form
          find('label[for="registration_agreed_to_terms"]').click
          click_on 'Confirm Payment'

          expect(page).to have_content('receipt confirming your registration')
          expect(page).to have_content('receipt confirming your membership')

          visit registration_order_path(RegistrationOrder.first)
          expect_correct_receipt_price(athlete1, event, discount: true)
          expect_correct_receipt_price(member_athlete, event, discount: true)
          expect_correct_receipt_price(non_member_athlete, event, discount: false)
        end
      end
    end

    def expect_correct_receipt_price(athlete, event, discount: false)
      item = ContestantItem.find_by(athlete_id: athlete.id)
      price = contestant_price(item, event, discount: discount)

      expect(page).to have_content "Contestant: #{athlete.name}: $#{price}"
    end

    def contestant_price(item, event, discount: false)
      base_price = event.event_registration_info.price_of(item)
      price = discount ? base_price - EventRegistrationInfo::UNAA_LEAGUE_MEMBER_DISCOUNT : base_price
    end

    def expect_correct_price_for_contestant(athlete, event, discount: false)
      item = ContestantItem.find_by(athlete_id: athlete.id)

      within data_test("item-#{item.id}") do
        expect(page).to have_content "Contestant: #{athlete.name}"
        expect(page).to have_content(contestant_price(item, event, discount: discount))
      end
    end

    def add_athlete_to_cart(athlete)
      within(data_test("athlete-#{athlete.id}")) do
        click_on 'Add To Cart' # opens tags selection dialog
      end

      within(data_test('tags-modal')) do
        click_on 'Add To Cart' # actually adds them to the cart
      end
    end

    def fill_in_card_form
      within_frame do
        Stripe::TestHelpers.fill_in_card_details(page)
      end
    end

    def enter_athlete_info(use_suggestion: false)
      fill_in 'Birthdate', with: '01/01/2000'
      choose 'Male'
      fill_in 'Name', with: 'John Smith'
      if use_suggestion
        first("[data-suggestion-index='0']").click
      else
        fill_in 'Display name', with: 'J Smith'
        fill_in 'Weight', with: '185 lbs'
        fill_in 'Height', with: '5\' 11"'
      end
    end
  end
end
