require 'rails_helper'

RSpec.describe 'Song', type: :system do
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

  describe 'edit' do
    let(:user) { create(:user) }
    let(:song) { create(:song, members: [user.member], audio: nil) }

    it 'enables logged-in users to update songs they played' do
      log_in_as user

      visit song_path(song)
      click_link '編集する'

      expect(page).to have_title('曲の編集')

      select '公開', from: 'song_status'
      fill_in 'song_comment', with: 'お気に入りの曲です'
      click_button '更新する'

      expect(page).to have_css('.alert-info')
      expect(song.reload.status).to eq 'open'
      expect(song.comment).to eq 'お気に入りの曲です'
    end
  end
end
