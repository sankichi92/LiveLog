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
    given(:admin) {create(:admin)}
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

      expect{click_button 'Add'}.to change(Live, :count).by(1)
      expect(page).to have_selector('.alert-success')
      expect(page).to have_title(name)
    end
  end
end
