require 'rails_helper'

RSpec.describe 'Users', type: :system do
  describe 'Signing up' do
    let(:user) { build(:user) }

    it 'allows user to sign up' do
      visit new_user_registration_path
      fill_in 'user[first_name]', with: user.first_name
      fill_in 'user[last_name]', with: user.last_name
      fill_in 'Organization Name', with: user.organization_name
      fill_in 'Email', with: user.email
      fill_in 'user[password]', with: 'password123'
      fill_in 'Password confirmation', with: 'password123'
      expect { click_on 'Sign up' }.to change(User, :count).by 1
      expect(page).to have_content 'Welcome! You have signed up successfully.'
      expect(User.last.first_name).to eq user.first_name
      expect(User.last.last_name).to eq user.last_name
      expect(User.last.email).to eq user.email
    end
  end

  describe 'Signing in' do
    let(:password) { 'password123' }
    let!(:user) do
      create(
        :user,
        password: password,
        password_confirmation: password
      )
    end

    it 'requires user to log in before visiting application' do
      visit root_path
      expect(page).to have_current_path(new_user_session_path)
    end

    it 'allows user to sign in' do
      visit new_user_session_path
      fill_in 'Email', with: user.email
      fill_in 'Password', with: password
      click_on 'Login'
      expect(page).to have_current_path(root_path)
      expect(page).to have_content('Signed in successfully.')
    end
  end

  describe 'Signing out' do
    let!(:user) { create(:user) }

    before do
      sign_in user
    end

    it 'allows user to sign out' do
      visit root_path
      click_on 'Sign Out'
      expect(page).to have_current_path(new_user_session_path)
      expect(page).to have_content('Login')
    end
  end

  describe 'Editing account info' do
    let(:password) { 'password123' }
    let!(:user) {
      create(
        :user,
        password: password,
        password_confirmation: password
      )
    }
    let(:new_user_info) {
      {
        first_name: 'New',
        last_name: 'Name',
        email: 'new_email@example.com'
      }
    }

    before do
      sign_in user
    end

    it 'allows user to update account info' do
      visit root_path
      click_on 'Edit Profile'
      fill_in 'First name', with: new_user_info[:first_name]
      fill_in 'Last name', with: new_user_info[:last_name]
      fill_in 'Email', with: new_user_info[:email]
      fill_in 'Current password', with: password
      click_on 'Update'
      expect(user.reload.first_name).to eq new_user_info[:first_name]
      expect(user.last_name).to eq new_user_info[:last_name]
      expect(user.email).to eq new_user_info[:email]
    end

    it 'does not show Organization name field if user is not org_admin' do
      visit edit_user_registration_path
      expect(page).not_to have_field 'Organization name'
      sign_out user

      org_admin = create(:user, role: 'org_admin')
      sign_in org_admin
      refresh

      expect(page).to have_field 'Organization name'
    end

    it 'allows org_admin user to update associated organization name' do
      user.update(role: 'org_admin')
      old_organization_name = user.organization_name
      new_organization_name = 'New Org Name'
      old_organization_id = user.organization.id

      visit edit_user_registration_path
      fill_in 'Organization name', with: new_organization_name
      fill_in 'Current password', with: password
      click_on 'Update'
      expect(user.organization.reload.name).to_not eq old_organization_name
      expect(user.organization_name).to eq new_organization_name

      # ensure it doesn't create a new organization
      expect(user.organization.id).to eq old_organization_id
    end
  end
end
