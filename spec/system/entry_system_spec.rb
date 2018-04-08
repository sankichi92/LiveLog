require 'rails_helper'

RSpec.describe 'Entry', type: :system do
  let(:live) { create(:live, :draft) }
  let(:user) { create(:user) }

  describe 'list' do
    let!(:entries) { create_list(:song, 10, :draft, live: live) }
    let(:player) { create(:user, nickname: '共演者') }
    let!(:user_entry) { create(:song, :draft, live: live, users: [user, player], name: 'Song user will play') }

    it 'enables logged-in users to see individual live entries pages and their applied songs' do
      log_in_as user
      visit root_path
      click_link live.name

      expect(page).to have_title(live.title)
      expect(page).to have_content(live.name)
      expect(page).to have_link(t('views.lives.entry'), href: new_live_entry_path(live))
      expect(page).not_to have_css('#admin-tools')
      expect(page).to have_content(user_entry.name)
      user_entry.playings.each do |playing|
        expect(page).to have_content(playing.handle)
      end
      entries.each do |entry|
        expect(page).not_to have_content(entry.name)
      end
    end

    it 'enables admin users to see individual live entries pages and all applied songs' do
      log_in_as create(:admin)
      visit live_entries_path(live)

      expect(page).to have_title(live.title)
      expect(page).to have_link(t('views.lives.entry'), href: new_live_entry_path(live))
      expect(page).to have_css('#admin-tools')
      live.songs.each do |entry|
        expect(page).to have_content(entry.name)
      end
    end
  end

  describe 'add' do
    let!(:player1) { create(:user, nickname: '一郎') }
    let!(:player2) { create(:user, nickname: '二郎') }

    before do
      ActionMailer::Base.deliveries.clear
      log_in_as user
    end

    it 'enables logged-in users to create new entries', js: true do
      visit new_live_entry_path(live)

      expect(page).to have_title('Entry')
      expect(page).to have_content('Entry')

      fill_in 'song_name', with: 'テストソング'
      fill_in 'song_artist', with: 'テストアーティスト'
      select 'サークル内', from: 'song_status'

      click_button 'add-member'
      click_button 'add-member'
      click_button class: 'remove-member', match: :first

      [player1, player2].each_with_index do |user, i|
        all('.inst-field')[i].set('Gt')
        all('.user-select')[i].find(:option, user.name_with_handle).select_option
      end

      fill_in 'entry_preferred_rehearsal_time', with: '23時以前'
      fill_in 'entry_preferred_performance_time', with: '20時以降'

      accept_confirm do
        click_button t('views.application.send')
      end

      expect(page).to have_css('.alert-success')
      expect(ActionMailer::Base.deliveries.size).to eq 1
    end
  end

  describe 'publish' do
    before { log_in_as create(:admin) }

    it 'enables admin users to publish live', elasticsearch: true do
      expect(TweetJob).to receive(:perform_now)

      visit live_entries_path(live)

      click_link t('views.lives.publish')

      expect(live.reload.published).to be true
      expect(live.published_at).to be_present
      expect(page).to have_css('.alert-success')
    end
  end
end
