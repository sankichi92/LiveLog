# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Song system:' do
  describe 'search' do
    let!(:beatles_song) { create(:song, artist: 'The Beatles', name: 'Yesterday') }

    before { Song.__elasticsearch__.refresh_index! }

    it 'enables users to search songs from the both of basic and advanced forms', :elasticsearch, :js do
      visit songs_path

      fill_in 'q', with: 'The Beatles'
      click_on '検索'

      expect(page).to have_content(beatles_song.name)

      click_on '詳細'
      fill_in 'artist', with: 'The Beatles'
      click_on '検索'

      expect(page).to have_content(beatles_song.name)

      fill_in 'name', with: 'NoResultsQuery'
      click_on '検索'

      expect(page).to have_no_content(beatles_song.name)
      expect(page).to have_css('.alert-danger')
    end
  end

  describe 'detail' do
    let!(:song) { create(:song, name: 'アンプラグドのテーマ', artist: 'アンプラグダーズ', members: create_list(:member, 2)) }

    before { Song.__elasticsearch__.refresh_index! }

    it 'enables users to see individual songs', :elasticsearch do
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

  specify 'A logged-in user edits their played song', :js do
    # Given
    members = create_list(:member, 3)
    song = create(:song, name: 'before', members:)
    user = create(:user, member: members.first)
    log_in_as user

    # When
    visit song_path(song)
    click_on '編集する'

    # Then
    expect(page).to have_title '曲の編集'
    expect(page).to have_css '.play-form', count: 3

    # When
    fill_in '曲名', with: 'after'
    click_on '削除', match: :first
    click_on '更新する'

    # Then
    expect(page).to have_content '更新しました'
    expect(page).to have_content 'after'
    expect(song.plays.count).to eq 2
  end
end
