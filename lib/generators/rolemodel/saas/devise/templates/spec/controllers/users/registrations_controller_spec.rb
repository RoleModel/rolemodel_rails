require 'rails_helper'

RSpec.describe Users::RegistrationsController, type: :request do
  let(:password) { 'password123' }
  let(:user) { build(:user) }

  describe '#create' do
    it 'creates a user and organization' do
      expect {
        post(user_registration_path, params: {
          user: {
            first_name: user.first_name,
            last_name: user.last_name,
            organization_attributes: {
              name: user.organization_name
            },
            email: user.email,
            password: password,
            password_confirmation: password
          }
        })
      }.to change(User, :count).by(1).and change(Organization, :count).by(1)
      expect(Organization.last).to eq User.last.organization
    end
  end

  describe '#update' do
    let(:new_user_info) do
      {
        first_name: 'New',
        last_name: 'Name',
        organization_name: 'New Organization',
        email: 'newemail@example.com',
        current_password: password
      }
    end

    before :each do
      user.save
      sign_in user
    end

    it 'updates the user and organization' do
      put(user_registration_path, params: { user: new_user_info })

      expect(user.reload.first_name).to eq new_user_info[:first_name]
      expect(user.last_name).to eq new_user_info[:last_name]
      expect(user.organization_name).to eq new_user_info[:organization_name]
      expect(user.email).to eq new_user_info[:email]
    end

    it 'does not update different organization when id is passed' do
      other_organization = create(:organization)
      new_user_info[:organization_id] = other_organization.id

      put(user_registration_path, params: { user: new_user_info })

      expect(user.reload.organization).not_to eq other_organization
      expect(user.organization.name).to eq new_user_info[:organization_name]
      expect(other_organization.reload.name).not_to eq new_user_info[:organization_name]
    end
  end
end
