# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Reporting', type: :system, js: true do
  let(:user) { create(:user) }
  let!(:basic_report) do
    create :blazer_dashboard, name: 'Basic Report'
  end

  before { sign_in user }

  context 'Happy Path' do
    it 'allows a user to show a report' do
      visit reports_dashboards_path
      expect(page).to have_current_path(reports_dashboards_path)
      expect(page).to have_content('Basic Report')
      click_on 'Show'
      expect(page).to have_current_path(reports_dashboard_path(basic_report))
      expect(page).to have_content('Basic Report')
    end
  end
end
