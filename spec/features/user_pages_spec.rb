require 'rails_helper'

RSpec.feature "UserPages", type: :feature do

  scenario 'A user can see the sign up page' do
    visit signup_path

    expect(page).to have_title(full_title('Sign up'))
    expect(page).to have_content('Sign up')
  end
end
