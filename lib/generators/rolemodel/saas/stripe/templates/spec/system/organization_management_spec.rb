require 'rails_helper'

RSpec.describe 'Organization Management', type: :system do
  let(:last_payment_date) { Date.current - 15.days }
  let(:paid_through_date) { Date.current + 15.days }
  let(:next_billing_date) { Date.current + 16.days }
  let(:mock_stripe_subscription) do
    build(:mock_stripe_subscription,
      price: 10.00, # ensure zero cents in test
      current_period_start: last_payment_date.to_time.to_i,
      current_period_end: paid_through_date.to_time.to_i)
  end
  let(:mock_payment_method) { build(:mock_stripe_source) }
  let(:upcoming_invoice) do
    build(:mock_stripe_invoice, amount_due: 1000)
  end

  let!(:subscription) do
    create(:subscription,
      paid_through_date: paid_through_date,
      next_billing_date: next_billing_date,
      organization: organization)
  end
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :org_admin, organization: organization) }

  describe 'authorized access' do
    before :each do
      sign_in user
    end

    it 'allows admins to edit the profile' do
      visit organization_path

      click_on 'Edit Profile'
      fill_in 'Address', with: '123 W ST Awesomeville, NC, 27526'
      fill_in 'Url', with: 'https://ninjagym.com'
      fill_in 'Description', with: 'This is an awesome gym'
      click_on 'Save'

      expect(page).to have_content('Organization successfully updated')
    end

    describe 'subscription' do
      describe 'displays flash message due to coronavirus susbcription extension' do
        let(:magic_date) {Date.new(2020, 3, 27)}

        it 'to subscriptions created before March 26,2020' do
          subscription.update(updated_at: magic_date)
          visit organization_path
          expect(flash_notice).to have_text('COVID-19')
        end

        it "but not to subscriptions created after March 26,2020" do
          subscription.update(updated_at: magic_date + 1.day)
          visit organization_path
          expect(page).to_not have_text('COVID-19')
        end

        context 'registration only' do
          before :each do
            allow(organization).to receive(:active_subscription).and_return(Subscription.default)
          end

          it "is an exception" do
            visit organization_path
            expect(page).to_not have_text('COVID-19')
          end
        end
      end

      describe 'with Stripe data' do
        before :each do
          allow(Stripe::Subscription).to receive(:retrieve).and_return(mock_stripe_subscription)
          allow(Stripe::Customer).to receive(:retrieve_source).and_return(mock_payment_method)
          allow(Stripe::Invoice).to receive(:upcoming).and_return(upcoming_invoice)
        end

        it 'shows admins their active subscription details' do
          visit organization_path

          paid_through_date_string = paid_through_date.strftime('%B %-e, %Y')
          next_billing_date_string = next_billing_date.strftime('%B %-e, %Y')
          expect(page).to have_text 'Subscription'
          expect(page).to have_content "Plan: #{subscription.display_name}"
          expect(page).to have_content "Description: #{subscription.description}"
          expect(page).to have_content "Paid Through: #{paid_through_date_string}"
          expect(page).to have_content "Next Billing Date: #{next_billing_date_string}"
          expect(page).to have_content 'Next Billing Amount: $10.00'
          expect(page).to have_content "Payment Method: #{subscription.display_payment_method}"
        end

        it 'gracefully omits certain irrelevant data about canceled subscriptions' do
          allow(mock_stripe_subscription).to receive(:delete)
          subscription.cancel

          visit organization_path
          expect(page).to have_content 'This subscription has been canceled. You will not be charged for it in the future.'
          expect(page).not_to have_content 'Next Billing Date: (none)'
          expect(page).not_to have_content 'Next Billing Amount: (none)'
        end
      end

      it 'displays \'(none)\' when the subscription lacks a piece of data' do
        subscription.update(next_billing_date: nil)

        visit organization_path
        expect(page).to have_content 'Next Billing Date: (none)'
        expect(page).to have_content 'Payment Method: (none)'
      end
    end
  end

  describe 'unauthorized access' do
    let(:regular_user) { create(:user, :regular_user, organization: organization) }

    it 'does not allow non-admins to manage the organization' do
      sign_in regular_user
      visit organization_path
      expect(page).to have_content 'not authorized'
    end
  end


  def flash_notice
    find('#notice')
  end

end
