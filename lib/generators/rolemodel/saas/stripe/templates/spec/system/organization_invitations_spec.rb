require 'rails_helper'

RSpec.describe 'Organization Invitations', type: :system do
  let(:organization) { create(:subscribed_organization, credits: 10) }
  let(:user) { create(:user, :org_admin, organization: organization) }

  def notice
    find('#notice')
  end

  before :each do
    sign_in user
  end

  describe 'as an org_admin' do
    it 'shows a link to the invitation form when the organization has credits' do
      visit organization_path(organization)
      click_on 'Gift Subscription'
      expect(page).to have_current_path new_organization_invitation_path
    end

    it 'shows no link to the invitation form when the organization lacks credits' do
      organization.update(credits: 0)
      visit organization_path(organization)
      expect(page).not_to have_content 'Gift Subscription'

      visit new_organization_invitation_path
      expect(page).to have_current_path organization_path
      expect(notice).to have_text 'Sorry, you are out of credits'
    end
  end

  def fill_out_invitation
    fill_in 'Name', with: 'Person'
    fill_in 'Email', with: 'person@example.com'
    click_on 'Send Invitation'
  end

  describe 'invitation form validations' do
    before :each do
      visit new_organization_invitation_path
    end

    it 'requires a name' do
      fill_in 'Email', with: 'person@example.com'
      click_on 'Send Invitation'
      expect(notice).to have_text "Users name can't be blank"
    end

    it 'requires an email' do
      fill_in 'Name', with: 'Person'
      click_on 'Send Invitation'
      expect(notice).to have_text "Users email can't be blank"
    end

    it 'allows the org_admin to continue when the both the name and email are valid' do
      fill_out_invitation
      expect(page).to have_current_path(organization_path)
    end
  end

  describe 'inviting a new participant organization' do
    before :each do
      sign_in user
      visit(organization_path)
      click_on 'Gift Subscription'
    end

    it 'sends an email to the user' do
      fill_out_invitation
      expect(Devise.mailer.deliveries.count).to eq(1)
    end

    it 'creates a new participant organization' do
      expect {
        fill_out_invitation
      }.to change(Organization, :count).by(1)
      expect(Organization.last.plan_category).to eq 'Participant'
    end

    it "spends one of the organization's credits" do
      expect {
        fill_out_invitation
        organization.reload
      }.to change(organization, :credits).by(-1)
    end
  end

  describe 'clicking the emailed set password link' do
    def send_invitation
      sign_in user
      visit organization_path
      click_on 'Gift Subscription'
      fill_out_invitation
      sign_out user
    end

    def accept_invitation
      email = Devise.mailer.deliveries.first
      raw_source = email.body.parts[0].body.raw_source
      link_regex = /http:\/\/localhost:3000\/app\/users\/invitation\/[a-z\/?_=A-Z0-9-]+/
      visit raw_source.match(link_regex)[0]
    end

    def fill_out_password_form
      fill_in 'user_password', with: '123456'
      fill_in 'user_password_confirmation', with: '123456'
      check 'I agree'
      click_on 'Create Account'
    end

    it 'sends invited participant to a page to finish creating their account' do
      send_invitation
      accept_invitation
      expect(page).to have_button('Create Account')
      fill_out_password_form
      click_on 'Login'
      expect(page).to have_current_path leader_boards_path
    end
  end
end
