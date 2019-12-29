require 'rails_helper'

RSpec.describe 'Live', type: :system do
  describe 'list' do
    before do
      create_list(:live, 2)
      create(:live, :unpublished, name: 'draft live')
    end

    it 'enables users to see the published lives' do
      visit lives_path

      expect(page).to have_title('ライブ')
      Live.published.each do |live|
        expect(page).to have_content(live.name)
      end
      Live.unpublished.each do |draft_live|
        expect(page).not_to have_content(draft_live.name)
      end
    end
  end

  describe 'detail' do
    let(:live) { create(:live, :with_songs, album_url: 'https://example.com/album') }

    it 'enables non-logged-in users to see individual live pages' do
      visit live_path(live)

      expect(page).to have_title(live.title)
      expect(page).to have_content(live.name)
      expect(page).to have_content(I18n.l(live.date))
      expect(page).to have_content(live.place)
      expect(page).not_to have_link(href: live.album_url)
      expect(page).not_to have_css('#admin-tools')
      live.songs.each do |song|
        expect(page).to have_content(song.name)
      end
    end

    it 'enables logged-in users to see individual live pages with an album link' do
      log_in_as create(:user)

      visit live_path(live)

      expect(page).to have_title(live.title)
      expect(page).to have_link(href: live.album_url)
      expect(page).not_to have_css('#admin-tools')
    end
  end
end
