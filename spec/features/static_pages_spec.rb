require 'rails_helper'

RSpec.feature "StaticPages", type: :feature do

  let(:base_title) { 'LiveLog' }

  scenario 'A user can see the Home page' do
    visit root_path

    expect(page).to have_title('LiveLog')
    expect(page).to have_content(base_title)
  end

  scenario 'A user can see the About page' do
    visit root_path

    click_on 'About'

    expect(page).to have_title("About | #{base_title}")
    expect(page).to have_content('LiveLog について')
  end
end
