require 'rails_helper'

RSpec.feature "LivePages", type: :feature do

  feature 'Index' do
    given(:live) { create(:live) }

    scenario 'A user can see the live page' do
      visit root_path
      click_link 'Live List'

      expect(page).to have_title('Live List')
      expect(page).to have_content('Live List')
    end
  end
end
