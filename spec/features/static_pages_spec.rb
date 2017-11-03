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
      expect(page).to have_link('Stats', href: stats_path)
      expect(page).to have_link('Log in', href: login_path)
      expect(page).not_to have_content("Today's Pickup!")
      expect(page).not_to have_content('Latest Lives')
    end

    feature "Today's Pickup!" do
      given!(:song) { create(:song, status: :open) }

      scenario 'A user can see the pickup song' do
        visit root_path

        expect(page).to have_content("Today's Pickup!")
        expect(page).to have_content(song.title)
        expect(page).to have_css('.embed-responsive')
      end
    end

    feature 'Latest Lives' do
      given(:new_live) { create(:live, date: 1.week.ago, name: '新ライブ') }
      given!(:old_live) { create(:live, date: 1.year.ago, name: '古ライブ') }
      given!(:draft_live) { create(:draft_live, name: '未来ライブ') }
      background { create(:song, live: new_live) }

      scenario 'A user can see the latest lives' do
        visit root_path

        expect(page).to have_content('Latest Lives')
        expect(page).to have_content(new_live.name)
        expect(page).to have_link('詳細へ', href: live_path(new_live))

        expect(page).not_to have_content(old_live.name)
        expect(page).not_to have_content(draft_live.name)
      end
    end
  end

  scenario 'A user can see the Stats page' do
    visit root_path

    click_on 'Stats'

    expect(page).to have_title(full_title('Stats'))
    expect(page).to have_content('Stats')
  end
end
