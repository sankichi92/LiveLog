require 'rails_helper'

RSpec.feature 'EntryPages', type: :feature do
  given(:live) { create(:live, date: Time.zone.today + 1.month) }

  feature 'Entry' do
    given(:user) { create(:user) }

    background { ActionMailer::Base.deliveries.clear }

    scenario 'A logged-in user can send an entry with valid information', js: true do
      log_in_as user
      visit new_live_entry_path(live)

      expect(page).to have_title('Entry')

      fill_in '曲名', with: 'テストソング'
      click_button 'Send'

      expect(page).to have_selector('.alert-success')
      expect(ActionMailer::Base.deliveries.size).to eq 1
    end

    scenario 'A logged-in user cannot send an entry with invalid information', js: true do
      log_in_as user
      visit new_live_entry_path(live)

      click_button 'Send'

      expect(page).to have_selector('.alert-danger')
      expect(ActionMailer::Base.deliveries.size).to eq 0
    end
  end
end
