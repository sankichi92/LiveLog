require 'rails_helper'

RSpec.describe 'Static pages', type: :system do
  describe 'Home' do
    it 'enables users to see the home page' do
      visit root_path

      expect(page).to have_title('LiveLog')
      expect(page).not_to have_title('-')
      expect(page).to have_link('Song Search', href: songs_path)
      expect(page).to have_link('Live List', href: lives_path)
      expect(page).to have_link('Members', href: users_path)
      expect(page).to have_link('Stats', href: stat_path('current'))
      expect(page).to have_link('Log in', href: login_path)
    end

    describe "Today's Pickup!" do
      let(:song) { create(:song, created_at: 1.day.ago) }

      before { allow(Song).to receive(:pickup) { song } }

      it "enables users to see Today's Pickup!" do
        visit root_path

        expect(page).to have_content("Today's Pickup!")
        expect(page).to have_content(song.name)
      end
    end

    describe 'Latest Lives' do
      let!(:lives) { create_list(:live, 10) }

      it 'enables users to see Latest Lives' do
        visit root_path

        expect(page).to have_content('Latest Lives')
        Live.latest.each do |live|
          expect(page).to have_content(live.name)
        end
      end
    end
  end
end
