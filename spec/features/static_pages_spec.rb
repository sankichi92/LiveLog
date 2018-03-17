require 'rails_helper'

RSpec.feature 'Static pages', type: :feature do

  feature 'Home page' do
    before { Rails.cache.clear }

    scenario 'A user can see the Home page' do
      visit root_path

      expect(page).to have_title('LiveLog')
      expect(page).not_to have_title('-')
      expect(page).to have_link('Song Search', href: songs_path)
      expect(page).to have_link('Live List', href: lives_path)
      expect(page).to have_link('Members', href: users_path)
      expect(page).to have_link('Stats', href: stat_path('current'))
      expect(page).to have_link('Log in', href: login_path)
    end

    feature "Today's Pickup!" do
      given!(:song) { create(:song, status: :open, created_at: 1.day.ago) }

      scenario 'A user can see the pickup song' do
        visit root_path

        expect(page).to have_content("Today's Pickup!")
        expect(page).to have_content(song.title)
        expect(page).to have_css('.song-thumbnail')
      end
    end

    feature 'Latest Lives' do
      given!(:live) { create(:live, name: '新ライブ') }
      given!(:draft_live) { create(:draft_live, name: '未来ライブ') }

      scenario 'A user can see the latest lives' do
        visit root_path

        expect(page).to have_content('Latest Lives')
        expect(page).to have_content(live.name)
        expect(page).not_to have_content(draft_live.name)
      end
    end
  end
end
