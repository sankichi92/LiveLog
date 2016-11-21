require 'rails_helper'

RSpec.feature "AuthenticationPages", type: :feature do

  scenario 'A user can see login page' do
    visit login_path

    expect(page).to have_content('Log in')
    expect(page).to have_title('Log in')
  end

  scenario 'A user cannot log in with invalid information' do
    visit login_path

    click_button 'Log in'

    expect(page).to have_title('Log in')
    expect(page).to have_selector('.alert-danger')

    click_link 'LiveLog'

    expect(page).not_to have_selector('.alert')
  end

  scenario 'A user can login and logout with valid information' do
    user = create(:user)
    log_in_as user

    expect(page).to have_content(user.full_name)
    expect(page).to have_link('Profile', href: user_path(user))
    expect(page).to have_link('Settings', href: edit_user_path(user))
    expect(page).to have_link('Log out', href: logout_path)
    expect(page).not_to have_link('Log in', href: login_path)
    expect(user.reload.remember_digest).to be_blank

    click_on 'Log out'

    expect(page).to have_link('Log in', href: login_path)
  end

  scenario 'A user can login with remembering' do
    user = create(:user)
    log_in_as user, remember_me: true

    expect(user.reload.remember_digest).not_to be_blank
  end

  feature 'authorization' do

    context 'for non-logged-in users' do
      given(:user) { create(:user) }

      scenario 'A non-logged-in user cannot visit edit page' do
        visit edit_user_path(user)
        expect(page).to have_title('Log in')
      end
    end
  end
end
