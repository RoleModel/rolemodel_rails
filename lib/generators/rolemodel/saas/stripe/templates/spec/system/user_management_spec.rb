require 'rails_helper'

RSpec.describe 'User Management', type: :system do
  let(:organization) { create(:subscribed_organization) }
  let(:user) { create(:user, :org_admin, organization: organization) }

  def notice
    find('#notice')
  end

  describe 'inviting a user' do
    context 'when a user can be invited' do
      it 'allows the adding of users' do
        sign_in user
        visit organization_path
        click_on 'Invite User'
        fill_in 'Name', with: 'John Smith'
        fill_in 'Email', with: 'john@me.com'
        find('.user-form__submit').click

        expect(page).to have_content('John Smith (invited)')
      end
    end

    it 'allows a user to accept an invitation', js: true do
      invited_user = User.invite!(email: 'new_user@example.com', name: 'John Doe', organization: organization) do |u|
        u.skip_invitation = true
        u.invitation_sent_at = DateTime.current
      end

      visit accept_user_invitation_path(invitation_token: invited_user.raw_invitation_token)
      fill_in 'Password', with: 'testing'
      fill_in 'Password Confirmation', with: 'testing'
      check 'I agree'
      click_on 'Create Account'

      expect(notice).to have_text 'You have successfully finished creating your account'
    end

    context 'invite user section' do
      context 'when users are invitable' do
        it 'shows how many user invitation are left not counting deleted users' do
          create(:user, organization: organization, deleted_at: Date.current)
          sign_in user
          visit organization_path
          invite_message = "You can invite up to #{Subscription::GYM_USERS - 1} more users to join your organization"

          expect(page).to have_content invite_message
        end
      end

      context 'when all the users have been invited' do
        before do
          organization.active_subscription.update(plan_category: 'SubscriptionPlan::Gym')
          invitable_user_count = SubscriptionPlan::Gym.new.max_user_count - 1
          invitable_user_count.times { |i| create(:user, organization: organization) }
          sign_in user
        end

        it 'shows how many user invitation are left' do
          visit organization_path
          expect(page).not_to have_content('Invite User')
        end
      end
    end
  end

  describe 'deactivating users' do
    let!(:other_user) { create(:user, organization: organization, name: 'William') }
    it 'allows users to be deactivated and reactivated' do
      sign_in user
      visit organization_path

      within('.active_users') do
        expect(page).to have_content other_user.name
        click_link "Deactivate"
      end
      expect(notice).to have_text 'User successfully deactivated'

      within('.deactivated_users') do
        expect(page).to have_content other_user.name
        click_on(id: 'organization__reactivate-user')
      end
      expect(notice).to have_text 'User successfully reactivated'

      expect(page).to have_content('Your organization does not have any deactivated users.')
    end
  end
end
