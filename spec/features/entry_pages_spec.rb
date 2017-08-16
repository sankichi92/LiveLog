require 'rails_helper'

RSpec.feature 'EntryPages', type: :feature do
  given(:live) { create(:live, date: Date.today + 1.month) }

  feature 'Entry' do
    given(:user) { create(:user) }

    scenario 'A non-logged-in user cannot visit a new entry page' do
      visit new_live_entry_path(live)

      expect(page).not_to have_title('Apply for song')
    end

    scenario 'A logged-in user can visit a new entry page' do
      log_in_as user
      visit new_live_entry_path(live)

      expect(page).to have_title('Apply for song')
    end
  end
end
