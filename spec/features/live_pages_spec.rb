require 'rails_helper'

RSpec.feature "LivePages", type: :feature do

  feature 'Show live list' do

    scenario 'A user can see the live page' do
      live = create(:live)
      visit root_path
      click_link 'Live List'

      expect(page).to have_title('Live List')
      expect(page).to have_content('Live List')
      expect(page).to have_content(live.name)
    end
  end

  feature 'Show individual live' do

    scenario 'A user can see the individual live page' do
      live = create(:live)
      visit live_path(live)

      expect(page).to have_title(live.name)
      expect(page).to have_content(live.name)
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
      expect(page).to have_title('New live')

      fill_in 'Name', with: name
      fill_in 'Date', with: '2016-11-23'
      fill_in 'Place', with: '4共31'

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

      expect(page).not_to have_title('Edit live')
      expect(page).not_to have_content('Edit live')
    end

    scenario 'An admin user cannot edit the live with blank name' do
      fill_in 'Name', with: ''
      click_button 'Save'

      expect(page).to have_selector('.alert-danger')
      expect(page).to have_title('Edit live')
    end

    scenario 'An admin user can edit the live with valid information' do
      new_name = 'New ライブ'
      new_date = Date.today

      fill_in 'Name', with: new_name
      fill_in 'Date', with: new_date
      click_button 'Save'

      expect(page).to have_selector('.alert-success')
      expect(live.reload.name).to eq new_name
      expect(live.reload.date).to eq new_date
      expect(page).to have_title('Live List')
    end
  end
end
