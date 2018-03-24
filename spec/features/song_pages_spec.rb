require 'rails_helper'

RSpec.feature 'Song pages', type: :feature do
  feature 'Show the song list' do
    background { create_list(:song, Song.per_page + 1) }

    scenario 'A user can see the first page of the published song list and move to the next page' do
      visit songs_path

      expect(page).to have_title('Song Search')
      expect(page).to have_content('Song Search')
      Song.published.page(1).each do |song|
        expect(page).to have_content(song.name)
      end
      Song.published.page(2).each do |song|
        expect(page).not_to have_content(song.name)
      end

      click_link '2'

      Song.published.page(2).each do |song|
        expect(page).to have_content(song.name)
      end
    end
  end

  feature 'Search songs' do
    given!(:beatles_song) { create(:song, artist: 'The Beatles') }

    background { Song.import }

    scenario 'A use can search songs from the both of basic and advanced forms', js: true do
      visit songs_path

      fill_in 'q', with: 'The Beatles'
      click_button 'Search'

      expect(page).to have_content(beatles_song.name)

      click_on 'Advanced'
      fill_in 'artist', with: 'The Beatles'
      click_button 'Search'

      expect(page).to have_content(beatles_song.name)

      fill_in 'name', with: 'No results'
      click_button 'Search'

      expect(page).not_to have_content(beatles_song.name)
      expect(page).to have_css('.alert-danger')
    end
  end

  feature 'Show a song detail' do
    given(:song) { create(:song, users: create_list(:user, 2)) }

    scenario 'A user can see a song detail and watch the video' do
      visit song_path(song)

      expect(page).to have_title(song.title)
      expect(page).to have_content(song.name)
      expect(page).to have_content(song.artist)
      expect(page).to have_content(song.live_name)
      expect(page).to have_content(song.time_order)
      song.playings.each do |playing|
        expect(page).to have_content(playing.handle)
      end
    end
  end

  feature 'Add a song' do
    given(:live) { create(:live) }
    given!(:user1) { create(:user, nickname: '一郎') }
    given!(:user2) { create(:user, nickname: '二郎') }

    background { log_in_as create(:admin) }

    scenario 'An admin user can create a new song with valid information', js: true do
      visit live_path(live)

      click_link 'Add song'

      expect(page).to have_title('Add Song')
      expect(page).to have_content('Add Song')

      fill_in 'song_order', with: '1'
      fill_in 'song_name', with: 'テストソング'
      fill_in 'song_artist', with: 'テストアーティスト'

      click_button 'add-member'
      click_button 'add-member'
      click_button class: 'remove-member', match: :first

      [user1, user2].each_with_index do |user, i|
        all('.inst-field')[i].set('Gt')
        all('.user-select')[i].find(:option, user.name_with_handle).select_option
      end

      expect { click_button 'Add' }.to change(Song, :count).by(1)
      expect(page).to have_selector('.alert-success')
    end
  end

  feature 'Edit a song' do
    given(:user) { create(:user) }
    given(:song) { create(:song, users: [user]) }

    scenario 'An admin user can update a song' do
      log_in_as create(:admin)

      visit song_path(song)
      click_link 'Edit'

      expect(page).to have_title('Edit Song')
      expect(page).to have_content('Edit Song')

      fill_in 'song_youtube_id', with: 'https://www.youtube.com/watch?v=new_youtube'
      click_button 'Save'

      expect(page).to have_selector('.alert-success')
      expect(song.reload.youtube_id).to eq 'new_youtube'
    end

    scenario 'A user can update a song he/she played' do
      log_in_as user

      visit song_path(song)
      click_link 'Edit'

      expect(page).to have_title('Edit Song')
      expect(page).to have_content('Edit Song')

      select '公開', from: 'song_status'
      fill_in 'song_comment', with: 'お気に入りの曲です'
      click_button 'Save'

      expect(page).to have_selector('.alert-success')
      expect(song.reload.status).to eq 'open'
      expect(song.comment).to eq 'お気に入りの曲です'
    end
  end

  feature 'Delete a song' do
    given(:song) { create(:song) }

    background { log_in_as create(:admin) }

    scenario 'An admin user can delete a song' do
      visit song_path(song)
      click_link 'Edit'

      expect { click_link('Delete') }.to change(Song, :count).by(-1)
    end
  end
end
