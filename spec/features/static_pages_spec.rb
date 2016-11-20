require 'rails_helper'

RSpec.feature "StaticPages", type: :feature do

  scenario 'A user can see the Home page' do
    visit root_path

    expect(page).to have_title(full_title(''))
    expect(page).not_to have_title('|')
    expect(page).to have_content('セットリスト検索システムです')
  end

  scenario 'A user can see the About page' do
    visit root_path

    click_on 'About'

    expect(page).to have_title(full_title('About'))
    expect(page).to have_content('LiveLog について')
  end
end
