require 'rails_helper'

RSpec.feature "SongPages", type: :feature do

  given(:admin) { create(:admin) }
  given(:live) { create(:live) }
  background { log_in_as admin }

  feature 'song creation' do
    background { visit new_song_path(live_id: live.id) }

    scenario 'with invalid information' do
      expect { click_button 'Add' }.not_to change(Song, :count)
      expect(page).to have_selector('.alert-danger')
    end

    scenario 'with valid information' do
      expect(page).to have_title('Add song')

      fill_in '曲名', with: 'テストソング'

      expect { click_button 'Add' }.to change(Song, :count).by(1)
      expect(page).to have_selector('.alert-success')
    end
  end
end
