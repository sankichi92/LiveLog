require 'rails_helper'

RSpec.describe 'Song system:', type: :system do
  describe 'search' do
    let!(:beatles_song) { create(:song, artist: 'The Beatles', name: 'Yesterday') }

    before { Song.__elasticsearch__.refresh_index! }

    it 'enables users to search songs from the both of basic and advanced forms', js: true, elasticsearch: true do
      visit songs_path

      fill_in 'q', with: 'The Beatles'
      click_button '検索'

      expect(page).to have_content(beatles_song.name)

      click_on '詳細'
      fill_in 'artist', with: 'The Beatles'
      click_button '検索'

      expect(page).to have_content(beatles_song.name)

      fill_in 'name', with: 'NoResultsQuery'
      click_button '検索'

      expect(page).not_to have_content(beatles_song.name)
      expect(page).to have_css('.alert-danger')
    end
  end

  describe 'detail' do
    let!(:song) { create(:song, name: 'アンプラグドのテーマ', artist: 'アンプラグダーズ', members: create_list(:member, 2)) }

    before { Song.__elasticsearch__.refresh_index! }

    it 'enables users to see individual songs', elasticsearch: true do
      visit song_path(song)

      expect(page).to have_title(song.title)
      expect(page).to have_content(song.name)
      expect(page).to have_content(song.artist)
      expect(page).to have_content(song.live.name)
      expect(page).to have_content(song.position)
      song.plays.each do |play|
        expect(page).to have_content(play.member.name)
      end
    end
  end

  specify 'A logged-in user edits their played song', js: true do
    # Given
    members = create_list(:member, 3)
    song = create(:song, name: 'before', members: members)
    user = create(:user, member: members.first)
    log_in_as user

    # When
    visit song_path(song)
    click_on '編集する'

    # Then
    expect(page).to have_title '曲の編集'
    expect(page).to have_selector '.play-form', count: 3

    # When
    fill_in '曲名', with: 'after'
    click_button '削除', match: :first
    click_button '更新する'

    # Then
    expect(page).to have_content '更新しました'
    expect(page).to have_content 'after'
    expect(song.plays.count).to eq 2
  end
end
