require 'rails_helper'

RSpec.feature 'EntryPages', type: :feature do
  given(:live) { create(:draft_live) }

  feature 'Show the entry list for the live' do
    given(:user) { create(:user) }
    given!(:their_entry) { create(:draft_song, live: live, name: 'Visible song', user: user) }
    given!(:other_entry) { create(:draft_song, live: live, name: 'Invisible song') }
    background do
      log_in_as user
    end

    scenario 'A logged-in user can see the entries only they will play' do
      visit root_path
      click_link live.name

      expect(page).to have_title(live.title)
      expect(page).to have_link('エントリーする', href: new_live_entry_path(live))
      expect(page).to have_content('Visible song')
      expect(page).not_to have_content('Invisible song')
    end
  end

  feature 'Create an entry' do
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
