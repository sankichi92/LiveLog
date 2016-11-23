require 'rails_helper'

RSpec.feature "LivePages", type: :feature do

  feature 'Index' do
    scenario 'A user can see the live page' do
      live = create(:live)
      visit root_path
      click_link 'Live List'

      expect(page).to have_title('Live List')
      expect(page).to have_content('Live List')
      expect(page).to have_content(live.name)
    end
  end

  feature 'Show' do
    scenario 'A user can see the individual live page' do
      live = create(:live)
      visit live_path(live)
      
      expect(page).to have_title(live.name)
      expect(page).to have_content(live.name)
    end
  end
end
