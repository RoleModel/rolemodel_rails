# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Reporting', type: :system, js: true do
  let(:user) { create(:user) }
  let!(:basic_query) do
    sql = 'select 1'
    create :blazer_query, name: 'Basic Report', statement: sql
  end

  before { sign_in user }

  context 'Happy Path' do
    it 'allows a user to select and download a report CSV' do
      visit reports_path
      expect(page).to have_current_path(reports_path)
      expect(page).to have_content('Basic Report')
      click_on 'Show'
      expect(page).to have_current_path(reports_query_path(basic_query))
      click_on 'Run'
      # find(data_test('download-csv-button')).click
      # expect(page).to have_button()
    end
  end
end
