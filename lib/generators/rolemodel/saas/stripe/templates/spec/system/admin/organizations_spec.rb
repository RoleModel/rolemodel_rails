require 'rails_helper'

RSpec.describe 'Support Admin View', type: :system do
  let!(:support_org) { create :subscribed_organization }
  let!(:active_org) { create :subscribed_organization, name: 'Active Foos', stripe_customer_id: '123456' }
  let(:active_org_admin) { create :user, :org_admin, organization: active_org }
  let(:active_org_event) { create :event, organization: active_org }
  let(:subscriptionless_org) { create :organization, name: 'Subscriptionless Foos' }

  let(:burger_menu) { '.bm-burger-button' }

  describe 'for support admins' do
    let(:support_admin) { create(:user, :support_admin, organization: support_org) }

    before :each do
      sign_in support_admin
    end

    it 'is accessible through the Burger Menu', js: true do
      visit manage_events_path
      find(burger_menu).click
      click_link 'Support'
      expect(page).to have_current_path admin_organizations_path
    end

    describe 'table of organizaions' do
      it 'lists all the organizations' do
        visit admin_organizations_path
        expect(page).to have_text ['Admin', 'Customer', '# of Events'].join("\n")
        buttons = ['Name', 'Plan', 'Status', 'Paid Thru', 'Next Bill', 'Last Event']
        buttons.each do |button|
          expect(page).to have_button button
        end
        expect(page).to have_text support_org.name
        expect(page).to have_text active_org.name
      end

      it 'shows last event date, subscription, and org admin details for each organization' do
        allow(Stripe::Subscription).to receive(:retrieve).and_return build(:mock_stripe_subscription)
        active_org_admin
        active_org_event

        visit admin_organizations_path
        active_entry = [
          active_org.name,
          active_org_admin.email,
          active_org.plan_category,
          'active',
          active_org.active_subscription.paid_through_date.strftime('%-d-%b-%Y'),
          active_org.active_subscription.next_billing_date.strftime('%-d-%b-%Y'),
          'Link'
        ]
        expect(page).to have_text active_entry.join("\n")
        expect(page).to have_content active_org_event.start_date
      end

      it 'gracefully displays organizations without subscriptions' do
        subscriptionless_org

        visit admin_organizations_path
        expect(page).to have_text [
          'Subscriptionless Foos', 'None', 'Registration', 'Inactive', 'None', 'None', 'None'
        ].join("\n")
      end
    end

    describe 'organization detail page' do
      it 'shows more info about the organization' do
        visit admin_organizations_path
        click_link(active_org.name, match: :first)
        expect(page).to have_content active_org.name
        expect(page).to have_content active_org.active_subscription.display_name
      end

      it 'links back to the organization list' do
        visit admin_organization_path(active_org)
        expect(page).to have_link 'Back to Organizations'
      end

      it 'has link for inviting new org admins to an existing organization' do
        visit admin_organization_path(active_org)
        click_on 'Invite Org Admin'
        expect(page).to have_current_path new_user_invitation_path(organization_id: active_org.id)
      end
    end

    describe 'editing a subscription' do
      let(:action_input) { 'subscription[subscription_descriptions_attributes][0][action]' }
      let(:reason_input) { 'subscription[subscription_descriptions_attributes][0][reason]' }
      let(:action) { 'change something about the subscription' }
      let(:reason) { 'because, you know, reasons' }

      def select_date(date, field)
        select date.strftime('%Y'), from: "#{field}_1i"
        select date.strftime('%B'), from: "#{field}_2i"
        select date.strftime('%-d'), from: "#{field}_3i"
      end

      it 'has a link to a page for editing the subscription' do
        visit admin_organizations_path
        click_link active_org.name
        find('.icon--edit').click
        expect(page).to have_current_path edit_admin_subscription_path(active_org.active_subscription)
      end

      it 'requires an action and reason to update the subscription' do
        visit edit_admin_subscription_path(active_org.active_subscription)
        click_button 'Save'
        expect(page).to have_text "Subscription descriptions action can't be blank and Subscription descriptions reason can't be blank"
      end

      it 'displays the actions and reasons subscription has been updated before' do
        visit edit_admin_subscription_path(active_org.active_subscription)
        fill_in action_input, with: action
        fill_in reason_input, with: reason
        click_button 'Save'
        visit edit_admin_subscription_path(active_org.active_subscription)
        expect(page).to have_content "1. Action: #{action}\nReason: #{reason}"
      end

      it 'allows you change the plan category of a subscription' do
        visit edit_admin_subscription_path(active_org.active_subscription)
        fill_in action_input, with: action
        fill_in reason_input, with: reason

        select 'League Gym', from: 'subscription_plan_category'
        click_button 'Save'
        expect(page).to have_current_path admin_organization_path(active_org)
        expect(page).to have_text 'League Gym'
      end

      it 'allows you to change the paid through date of a subscription' do
        new_date = Date.current + 1.year

        visit edit_admin_subscription_path(active_org.active_subscription)
        fill_in action_input, with: action
        fill_in reason_input, with: reason

        select_date(new_date, 'subscription_paid_through_date')
        click_button 'Save'
        expect(page).to have_text 'The Subscription was successfully updated'
        expect(page).to have_text new_date.strftime('%-d-%b-%Y')
      end
    end

    it 'allows super admin to visit another orgs event' do
      active_org_event

      visit admin_organizations_path
      click_link(active_org.name)
      click_link(active_org_event.name)
      expect(page).to have_current_path event_courses_path(active_org_event)
    end

    context 'has user with athlete' do
      let(:active_org_with_users) { create :subscribed_organization, name: 'Active Foos With Users', braintree_customer_id: '123457' }
      let(:active_org_event_with_users) { create :event, organization: active_org_with_users }
      let!(:user) { create(:user, organization: active_org_with_users) }
      let!(:athlete) { create(:athlete, user: user, name: 'James') }

      it 'allows super admin to visit another orgs user athletes', js: true do
        active_org_event_with_users

        visit admin_organizations_path
        click_link(active_org_with_users.name)
        click_on 'View Athletes'

        expect(page).to have_content "Admin: Athletes for #{user.name}"
        expect(page).to have_content athlete.name
        expect(page).to have_current_path admin_user_athletes_path(user)
      end

      it 'prevents a regular user from visiting another orgs user athletes' do
        support_admin.update(role: 'user')
        active_org_event_with_users

        visit admin_user_athletes_path(user)
        expect(page).to have_content 'You are not authorized to perform this action'
      end
    end

    describe 'inviting a new organization' do
      it 'allows super admin to invite the new admin' do
        visit admin_organizations_path
        click_link 'Invite Organization'
        expect(page).to have_current_path new_organization_invitation_path
        fill_in 'Name', with: 'Foo Bar'
        fill_in 'Email', with: 'foo@bar.com'
        fill_in 'Organization Name', with: 'Baz'
        select 'Gym', from: 'Plan'
        click_button 'Send Invitation'
        expect(page).to have_current_path admin_organizations_path
        expect(page).to have_content ['Baz', 'foo@bar.com'].join("\n")
      end

      it 'requires a valid email address' do
        visit admin_organizations_path
        click_link 'Invite Organization'
        fill_in 'Name', with: 'Foo Bar'
        fill_in 'Email', with: 'invalid_email.com'
        fill_in 'Organization Name', with: 'Baz'
        click_button 'Send Invitation'
        expect(page).to have_content 'Users email is invalid'
      end

      it 'requires user to fully fill out the form' do
        visit admin_organizations_path
        click_link 'Invite Organization'
        click_button 'Send Invitation'
        expect(page).to have_content "Users email can't be blank, Users organization name can't be blank, and Users name can't be blank"
      end
    end

    describe 'inviting a new organization' do
      def send_invitation
        visit admin_organizations_path
        click_link 'Invite Organization'
        fill_in 'Name', with: 'Foo Bar'
        fill_in 'Email', with: 'foo@bar.com'
        fill_in 'Organization Name', with: 'Baz'
        select 'Gym', from: 'Plan'
        click_button 'Send Invitation'
      end

      def accept_invitation
        email = Devise.mailer.deliveries.first
        raw_source = email.body.parts[0].body.raw_source
        link_regex = %r{http://localhost:3000/app/users/invitation/[a-z\/?_=A-Z0-9-]+}
        visit raw_source.match(link_regex)[0]
        fill_in 'user_password', with: '123456'
        fill_in 'user_password_confirmation', with: '123456'
        checkbox_and_submit = all('input')[2]
        checkbox_and_submit.click
      end

      it 'includes new subscription credits' do
        send_invitation
        accept_invitation
        gym_org = Organization.find_by(name: 'Baz')
        expect(gym_org.credits).to eq SubscriptionPlan::Gym.new.initial_credits
      end
    end
  end

  describe 'preventing access' do
    describe 'for org admins' do
      let(:org_admin) { create(:user, :org_admin, organization: support_org) }

      it 'does not have a link on the Burger Menu', js: true do
        sign_in org_admin
        visit manage_events_path
        find(burger_menu).click
        expect(page).not_to have_link 'Support'
      end

      it 'does not allow the user to view all the organizations' do
        sign_in org_admin
        visit admin_organizations_path
        expect(page).to have_content 'not authorized'
      end
    end

    describe 'for regular users' do
      let(:regular_user) { create(:user, :regular_user, organization: support_org) }

      it 'does not have a link on the Burger Menu', js: true do
        sign_in regular_user
        visit manage_events_path
        find(burger_menu).click
        expect(page).not_to have_link 'Support'
      end

      it 'does not allow the user to view all the organizations' do
        sign_in regular_user
        visit admin_organizations_path
        expect(page).to have_content 'not authorized'
      end
    end
  end
end
