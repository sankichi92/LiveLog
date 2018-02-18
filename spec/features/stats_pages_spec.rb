require 'rails_helper'

RSpec.feature 'Static pages', type: :feature do
  background do
    create(:song)
  end

  scenario 'A user can see the stats page' do
    visit root_path

    click_on 'Stats'

    expect(page).to have_title(full_title('Stats'))
    expect(page).to have_content('Stats')
  end
end
