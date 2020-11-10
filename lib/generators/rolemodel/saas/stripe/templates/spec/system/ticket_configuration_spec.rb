require 'rails_helper'

RSpec.describe 'Ticket Configuration', type: :system do
  # Organization and user
  let(:organization) { create(:subscribed_organization) }
  let(:user) { create(:user, organization: organization) }
  # Setup event
  let!(:event) { create(:scheduled_event, organization: user.organization) }

  before :each do
    sign_in user
  end

  describe 'updating the default ticket price', js: true do
    it 'updates the event registration info' do
      visit configure_tickets_event_path(event)

      fill_in 'Ticket Name', with: 'All Competitors'
      fill_in 'Price', with: '40.00'
      fill_in 'Comment', with: 'includes tax'

      click_on 'Save'

      expect(page).to have_content 'Ticket Saved'
      expect(event.reload.event_registration_info.price_name).to eq 'All Competitors'
      expect(event.event_registration_info.price).to eq 40
      expect(event.event_registration_info.price_comment).to eq 'includes tax'
    end

    it 'with missing fields, does not update' do
      visit configure_tickets_event_path(event)

      fill_in 'Ticket Name', with: ''
      fill_in 'Price', with: ''

      click_on 'Save'

      expect(page).to have_content "Price can't be blank" and "Price name can't be blank"
    end
  end

  describe 'creating spectator tickets', js: true do
    it 'saves the ticket to the event' do
      visit configure_tickets_event_path(event)

      click_on '+ Add Spectator Ticket'

      within '#tickets' do
        fill_in 'Ticket Name', with: 'Random'
        fill_in 'Price', with: '23.19'
        fill_in 'Comment', with: 'includes tax'

        click_on 'Save'
      end

      expect(page).to have_content 'Ticket Saved'
      ticket = event.tickets.first
      expect(ticket.name).to eq 'Random'
      expect(ticket.price).to eq 23.19
      expect(ticket.comment).to eq 'includes tax'
    end
  end

  describe 'updating spectator tickets', js: true do
    let!(:ticket) { create(:ticket, event: event) }

    it 'updates the ticket' do
      visit configure_tickets_event_path(event)

      within '#tickets' do
        find('.accordion').click

        fill_in 'Ticket Name', with: 'Crazy'
        fill_in 'Price', with: '55.12'
        fill_in 'Comment', with: 'just do it'

        click_on 'Save'
      end

      expect(page).to have_content 'Ticket Saved'
      ticket.reload
      expect(ticket.name).to eq 'Crazy'
      expect(ticket.price).to eq 55.12
      expect(ticket.comment).to eq 'just do it'
    end
  end

  describe 'updating price variations', js: true do
    let!(:event_registration_info) { create(:event_registration_info, event: event) }
    let!(:price_variation) { create(:price_variation, event_registration_info: event_registration_info, tags: ['adults']) }

    it 'updates the variation' do
      visit configure_tickets_event_path(event)

      within '#variations' do
        find('.accordion').click

        fill_in 'Ticket Name', with: 'Variety'
        fill_in 'Price', with: '5.12'
        fill_in 'Comment', with: 'it'
        find('.pill', match: :first).click

        click_on 'Save'
      end

      expect(page).to have_content 'Ticket Saved'
      price_variation.reload
      expect(price_variation.name).to eq 'Variety'
      expect(price_variation.price).to eq 5.12
      expect(price_variation.comment).to eq 'it'
      expect(price_variation.tags).to eq ['kids']
    end
  end

  describe 'creating price variations', js: true do
    let!(:event_registration_info) { create(:event_registration_info, event: event) }

    it 'updates the variation' do
      visit configure_tickets_event_path(event)

      click_on '+ Add Price Variation'

      within '#variations' do
        fill_in 'Ticket Name', with: 'New Variation'
        fill_in 'Price', with: '1.23'
        fill_in 'Comment', with: 'polynesian'
        find('.pill', match: :first).click

        click_on 'Save'
      end

      expect(page).to have_content 'Ticket Saved'
      price_variation = event_registration_info.price_variations.first
      expect(price_variation.name).to eq 'New Variation'
      expect(price_variation.price).to eq 1.23
      expect(price_variation.comment).to eq 'polynesian'
      expect(price_variation.tags).to eq ['kids']
    end
  end

  describe 'setting league member discount true', js: true do
    let(:league) { create :league, :unaa, events_require_membership: true  }
    let(:unaa_sanction) do
      create(
        :sanction,
        league: league,
        rule_set: RuleSet::UNAA,
        run_scoring_strategy_name: UNAAQualifierRecap
      )
    end

    let!(:event) do
      create(:scheduled_event,
        organization: user.organization,
        default_rule_set: unaa_sanction.rule_set,
        sanction: unaa_sanction,
        tag_config: unaa_sanction.season.tag_config
      )
    end

    let!(:course) { create :course, event: event, sanction: unaa_sanction }
    let!(:event_registration_info) { create(:event_registration_info, event: event) }

    it 'is only available if league events_require_membership is enabled' do
      league.update(events_require_membership: false)

      visit configure_tickets_event_path(event)

      expect(page).to have_no_content 'Enable discount for league members'
    end

    it 'updates the info' do

      visit configure_tickets_event_path(event)

      find('label[for="event_registration_info_league_member_discount"]', match: :first).click

      expect(page).to have_content 'Athlete Tickets'

      event_registration_info.reload
      expect(event_registration_info.league_member_discount).to be_truthy
    end

    context 'enabled' do
      before do
        event_registration_info.update(league_member_discount: true)
      end

      it 'shows the price for members next to the default price' do
        visit configure_tickets_event_path(event)

        fill_in 'Price', with: '60.00'

        expect(page).to have_content '$50 for league members'
      end

      it 'shows the price for members next to the price variation' do
        visit configure_tickets_event_path(event)

        click_on '+ Add Price Variation'

        within '#variations' do
          find('.accordion').click

          fill_in 'Price', with: '40.00'

          expect(page).to have_content '$30 for league members'
        end
      end
    end

    it 'shows the price for members next to the default price' do
      visit configure_tickets_event_path(event)

      expect(page).to have_no_content '$50 for league members'

      find('label[for="event_registration_info_league_member_discount"]', match: :first).click

      fill_in 'Price', with: '60.00'

      expect(page).to have_content '$50 for league members'
    end
  end
end
