require 'rails_helper'

RSpec.feature 'LivePages', type: :feature do

  feature 'Show live list' do
    before do
      4.times { create(:live) }
    end

    scenario 'A user can see the live page' do
      visit lives_path

      expect(page).to have_title('Live List')
      expect(page).to have_content('Live List')
      Live.all.each do |live|
        expect(page).to have_selector('td', text: live.name)
      end
    end
  end

  feature 'Show individual live' do
    given(:live) { create(:live) }
    given(:song) { create(:song, live: live) }
    given(:user) { create(:user) }
    background { create(:playing, user: user, song: song) }

    scenario 'A user can see the individual live page' do
      visit live_path(live)

      expect(page).to have_title(live.name)
      expect(page).to have_content(live.name)
      expect(page).to have_content(song.name)
      expect(page).to have_content(user.handle)
      expect(page).not_to have_link(href: live.album_url)
    end
  end

  feature 'Add live' do
    given(:admin) { create(:admin) }
    background do
      log_in_as admin
      visit new_live_path
    end

    scenario 'A non-admin user cannot see the add live page' do
      log_in_as create(:user)
      visit new_live_path

      expect(page).not_to have_title('New live')
      expect(page).not_to have_content('New live')
    end

    scenario 'An admin user cannot create new live with invalid information' do
      expect { click_button 'Add' }.not_to change(Live, :count)
      expect(page).to have_selector('.alert-danger')
    end

    scenario 'An admin user can create a new live with valid information' do
      name = 'テストライブ'
      expect(page).to have_title('New Live')

      fill_in 'ライブ名', with: name
      fill_in '開催日', with: '2016-11-23'
      fill_in '場所', with: '4共31'

      expect { click_button 'Add' }.to change(Live, :count).by(1)
      expect(page).to have_selector('.alert-success')
      expect(page).to have_title(name)
    end
  end

  feature 'Edit live' do
    given(:live) { create(:live) }
    given(:admin) { create(:admin) }
    background do
      log_in_as admin
      visit edit_live_path(live)
    end

    scenario 'A non-admin user cannot see the edit live page' do
      log_in_as create(:user)
      visit edit_live_path(live)

      expect(page).not_to have_title('Edit Live')
      expect(page).not_to have_content('Edit Live')
    end

    scenario 'An admin user cannot edit the live with blank name' do
      fill_in 'ライブ名', with: ''
      click_button 'Save'

      expect(page).to have_selector('.alert-danger')
      expect(page).to have_title('Edit Live')
    end

    scenario 'An admin user can edit the live with valid information' do
      new_name = 'New ライブ'
      new_date = Time.zone.today

      fill_in 'ライブ名', with: new_name
      fill_in '開催日', with: new_date
      click_button 'Save'

      expect(page).to have_selector('.alert-success')
      expect(live.reload.name).to eq new_name
      expect(live.reload.date).to eq new_date
    end
  end

  feature 'Delete live' do
    given(:admin) { create(:admin) }
    given(:live) { create(:live) }

    scenario 'A user cannot see delete link' do
      visit live_path(live)
      expect(page).not_to have_selector('.fa-trash')
    end

    scenario 'An admin user can delete live' do
      log_in_as admin
      visit live_path(live)

      expect { click_link('Delete', match: :first) }.to change(Live, :count).by(-1)
    end
  end
end
