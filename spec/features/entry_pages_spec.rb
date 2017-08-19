require 'rails_helper'

RSpec.feature 'EntryPages', type: :feature do
  given(:live) { create(:live, date: Date.today + 1.month) }

  feature 'Entry', js: true do
    given(:user) { create(:user) }

    background { ActionMailer::Base.deliveries.clear }

    scenario 'A non-logged-in user cannot visit a new entry page' do
      visit new_live_entry_path(live)

      expect(page).not_to have_title('Apply for song')
    end

    scenario 'A logged-in user can send an entry with valid information' do
      log_in_as user
      visit new_live_entry_path(live)

      expect(page).to have_title('Apply for song')

      fill_in '曲名', with: 'テストソング'

      expect { click_button 'Send' }.to change(Song, :count).by(1)
      expect(page).to have_selector('.alert-info')
      expect(ActionMailer::Base.deliveries.size).to eq 1
    end

    scenario 'A logged-in user cannot send an entry with invalid information' do
      log_in_as user
      visit new_live_entry_path(live)

      expect { click_button 'Send' }.not_to change(Song, :count)
      expect(page).to have_selector('.alert-danger')
      expect(ActionMailer::Base.deliveries.size).to eq 0
    end
  end
end
