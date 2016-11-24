require 'rails_helper'

RSpec.feature "SongPages", type: :feature do

  given(:song) { create(:song) }

  feature 'show song' do
    given(:user) { create(:user) }

    scenario 'A non-logged-in user cannot see the song page' do
      visit song_path(song)

      expect(page).not_to have_title(song.name)
      expect(page).not_to have_content(song.name)
      expect(page).to have_selector('.alert-danger')
    end

    scenario 'A logged-in user can see the song page' do
      log_in_as user
      visit song_path(song)

      expect(page).to have_title(song.name)
      expect(page).to have_content(song.name)
    end
  end

  feature 'song creation' do
    given(:admin) { create(:admin) }
    given(:live) { create(:live) }
    background do
      log_in_as admin
      visit new_song_path(live_id: live.id)
    end

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

  feature 'song edition' do
    given(:admin) { create(:admin) }

    scenario 'A user cannot see the edit page' do
      visit edit_song_path(song)

      expect(page).not_to have_content('Edit song')
      expect(page).not_to have_title('Edit song')
      expect(page).to have_selector('.alert-danger')
    end

    scenario 'An admin user cannot save changes with invalid information' do
      log_in_as admin
      visit edit_song_path(song)

      fill_in '曲名', with: ''
      click_button 'Save'

      expect(page).to have_selector('.alert-danger')
    end

    scenario 'An admin user not save changes with invalid information' do
      new_song_name = 'ニューソング'
      log_in_as admin
      visit edit_song_path(song)

      fill_in '曲名', with: new_song_name
      click_button 'Save'

      expect(page).to have_selector('.alert-success')
      expect(song.reload.name).to eq new_song_name
    end
  end
end
