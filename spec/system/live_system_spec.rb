require 'rails_helper'

RSpec.describe 'Live', type: :system do
  describe 'list' do
    before do
      create_list(:live, 2)
      create(:live, :draft, name: 'draft live')
    end

    it 'enables users to see the published lives' do
      visit lives_path

      expect(page).to have_title('Live List')
      expect(page).to have_content('Live List')
      Live.published.each do |live|
        expect(page).to have_content(live.name)
      end
      Live.drafts.each do |draft_live|
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

    it 'enables admin users to see individual live page with admin tools' do
      log_in_as create(:admin)

      visit live_path(live)

      expect(page).to have_title(live.title)
      expect(page).to have_link(href: live.album_url)
      expect(page).to have_css('#admin-tools')
    end
  end

  describe 'add' do
    before { log_in_as create(:admin) }

    it 'enables admin users to create new lives' do
      visit new_live_path

      expect(page).to have_title('New Live')

      fill_in 'live_name', with: 'テストライブ'
      fill_in 'live_date', with: '2016-11-23'
      fill_in 'live_place', with: '4共31'

      expect { click_button t('helpers.submit.create') }.to change(Live, :count).by(1)
      expect(page).to have_css('.alert-success')
      expect(page).to have_title('テストライブ')
    end
  end

  describe 'edit' do
    let(:live) { create(:live) }

    before { log_in_as create(:admin) }

    it 'enables admin users to update lives' do
      visit edit_live_path(live)

      expect(page).to have_title('Edit Live')

      fill_in 'live_album_url', with: 'https://example.com/album'
      click_button t('helpers.submit.update')

      expect(live.reload.album_url).to eq 'https://example.com/album'
      expect(page).to have_css('.alert-success')
      expect(page).to have_title(live.title)
    end
  end

  describe 'delete' do
    let(:live) { create(:live) }

    before { log_in_as create(:admin) }

    it 'enables admin users to delete lives' do
      visit live_path(live)

      expect { click_link t('views.application.delete') }.to change(Live, :count).by(-1)
    end
  end
end
