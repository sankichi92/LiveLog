require 'rails_helper'

RSpec.feature "AuthenticationPages", type: :feature do

  subject { page }

  scenario 'A user can see login page' do
    visit login_path

    is_expected.to have_content('Log in')
    is_expected.to have_title('Log in')
  end

  scenario 'A user cannot log in with invalid information' do
    visit login_path

    click_button 'Log in'

    is_expected.to have_title('Log in')
    is_expected.to have_selector('.alert-danger')

    click_link 'LiveLog'

    is_expected.not_to have_selector('.alert')
  end

  scenario 'A user can log in with valid information' do
    user = create(:user)
    visit login_path

    fill_in 'Email', with: user.email.upcase
    fill_in 'Password', with: user.password
    click_button 'Log in'

    is_expected.to have_content(user.full_name)
    is_expected.to have_link('Log out', href: logout_path)
    is_expected.not_to have_link('Log in', href: login_path)
  end
end
