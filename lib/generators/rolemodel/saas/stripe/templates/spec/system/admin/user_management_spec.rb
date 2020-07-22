require 'rails_helper'

RSpec.describe 'User Management', type: :system do
  let(:organization) { create(:subscribed_organization) }
  let(:user) { create(:user, :org_admin, organization: organization) }
  let(:support_admin) do
    create(:user, :support_admin, organization: organization)
  end
  describe 'creating new user' do
    before :each do
      sign_in support_admin
      visit(admin_organizations_path)
      click_on 'Initial Organization'
      click_on 'Invite Org Admin'
    end

    it 'sends an email to the user' do
      # Finds element by id
      fill_in 'user_name', with: user.name
      fill_in 'user_email', with: 'person6@example.com'
      click_on 'Send Invitation'
      expect(Devise.mailer.deliveries.count).to eq(1)
    end
  end

  describe 'clicking the emailed set password link' do
    before :each do
      sign_in support_admin
      visit(admin_organizations_path)
      click_on 'Initial Organization'
      click_on 'Invite Org Admin'
      fill_in 'user_name', with: user.name
    end

    it 'redirects to a page to set your password' do
      fill_in 'user_email', with: 'person8@example.com'
      click_on 'Send Invitation'
      visit(emailed_link)
      expect(page).to have_button('Create Account')
    end

    context 'filling out the set password form' do
      it 'successfully completes the account' do
        fill_in 'user_email', with: 'person7@example.com'
        click_on 'Send Invitation'
        visit(emailed_link)
        new_password = 'new_password'
        fill_in 'user_password', with: new_password
        fill_in 'user_password_confirmation', with: new_password
        check 'I agree'
        click_on 'Create Account'
        expect(page).to have_content('You have successfully finished creating your account')
      end
    end
  end

  def link_regex
    %r{http://\w+(:\d*|\.\w{2,})/[a-z/?_=A-Z0-9-]+} # https://stackoverflow.com/questions/25240102/how-to-visit-a-link-inside-an-email-using-capybara
  end

  def emailed_link
    email = Devise.mailer.deliveries.first
    raw_source = email.body.parts[0].body.raw_source # Get the raw text of the email
    link_path = raw_source.match(link_regex)[0]
  end
end
