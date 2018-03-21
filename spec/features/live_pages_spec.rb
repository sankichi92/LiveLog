require 'rails_helper'

RSpec.feature 'Live pages', type: :feature do
  feature 'Show the live list' do
    background do
      create_list(:live, 2)
      create(:draft_live, name: 'draft live')
    end

    scenario 'A user can see the published live list' do
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

  feature 'Show a live detail' do
    given(:live) { create(:live, :with_songs) }

    scenario 'A non-logged-in user can see a live page' do
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

    scenario 'A logged-in user can see a live page with an album link' do
      log_in_as create(:user)

      visit live_path(live)

      expect(page).to have_title(live.title)
      expect(page).to have_link(href: live.album_url)
      expect(page).not_to have_css('#admin-tools')
    end

    scenario 'An admin user can see a live page with admin tools' do
      log_in_as create(:admin)

      visit live_path(live)

      expect(page).to have_title(live.title)
      expect(page).to have_link(href: live.album_url)
      expect(page).to have_css('#admin-tools')
    end
  end

  feature 'Add a live' do
    background { log_in_as create(:admin) }

    scenario 'An admin user can create a new live with valid information' do
      visit new_live_path

      expect(page).to have_title('New Live')

      fill_in 'live_name', with: 'テストライブ'
      fill_in 'live_date', with: '2016-11-23'
      fill_in 'live_place', with: '4共31'

      expect { click_button 'Add' }.to change(Live, :count).by(1)
      expect(page).to have_css('.alert-success')
      expect(page).to have_title('テストライブ')
    end
  end

  feature 'Edit a live' do
    given(:live) { create(:live) }

    background { log_in_as create(:admin) }

    scenario 'An admin user can update a live with valid information' do
      visit edit_live_path(live)

      expect(page).to have_title('Edit Live')

      fill_in 'live_album_url', with: 'https://example.com/album'
      click_button 'Save'

      expect(page).to have_selector('.alert-success')
      expect(live.reload.album_url).to eq 'https://example.com/album'
    end
  end

  feature 'Delete a live' do
    given(:live) { create(:live) }

    background { log_in_as create(:admin) }

    scenario 'An admin user can delete a live' do
      visit live_path(live)

      expect { click_link('Delete') }.to change(Live, :count).by(-1)
    end
  end
end
