require 'rails_helper'

RSpec.describe 'Entry', type: :system do
  let(:live) { create(:live, :draft) }
  let(:user) { create(:user) }

  describe 'list' do
    let!(:user_song) { create(:song, :draft, name: 'applied song', live: live, members: [user.member, create(:member)]) }
    let!(:other_song) { create(:song, :draft, name: 'other song', live: live) }

    it 'enables logged-in users to see individual live entries pages and their applied songs' do
      log_in_as user
      visit root_path
      click_link live.name

      expect(page).to have_title(live.title)
      expect(page).to have_content(live.name)
      expect(page).to have_link('エントリーする', href: new_live_entry_path(live))
      expect(page).not_to have_css('#admin-tools')
      expect(page).to have_content(user_song.name)
      user_song.playings.each do |playing|
        expect(page).to have_content(playing.member.name)
      end
      expect(page).not_to have_content(other_song.name)
    end

    it 'enables admin users to see individual live entries pages and all applied songs' do
      log_in_as create(:admin)
      visit live_entries_path(live)

      expect(page).to have_title(live.title)
      expect(page).to have_link('エントリーする', href: new_live_entry_path(live))
      expect(page).to have_css('#admin-tools')
      live.songs.each do |entry|
        expect(page).to have_content(entry.name)
      end
    end
  end

  describe 'add' do
    let!(:members) { create_list(:member, 5) }

    before do
      ActionMailer::Base.deliveries.clear
      log_in_as user
    end

    it 'enables logged-in users to create new entries', js: true do
      visit new_live_entry_path(live)

      expect(page).to have_title('Entry')
      expect(page).to have_content('Entry')

      2.times do
        click_button 'add-member'
      end
      click_button class: 'remove-member', match: :first

      fill_in 'song_name', with: 'テストソング'
      fill_in 'song_artist', with: 'テストアーティスト'
      select 'サークル内', from: 'song_status'

      [user.member, members.first].each_with_index do |member, i|
        all('.inst-field')[i].set('Gt')
        all('.member-select')[i].find(:option, member.joined_year_and_name).select_option
      end

      fill_in 'entry_preferred_rehearsal_time', with: '23時以前'
      fill_in 'entry_preferred_performance_time', with: '20時以降'

      accept_confirm do
        click_button '送信する'
      end

      expect(page).to have_css('.alert-info')
      expect(ActionMailer::Base.deliveries.size).to eq 1
    end
  end

  describe 'publish' do
    let(:tweet_job) { class_spy(TweetJob) }

    before do
      stub_const('TweetJob', tweet_job)

      log_in_as create(:admin)
    end

    it 'enables admin users to publish live', elasticsearch: true do
      visit live_entries_path(live)

      click_link '公開する'

      expect(tweet_job).to have_received(:perform_now)
      expect(live.reload.published).to be true
      expect(live.published_at).to be_present
      expect(page).to have_css('.alert-info')
    end
  end
end
