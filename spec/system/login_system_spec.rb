require 'rails_helper'

RSpec.describe 'Login', type: :system do
  let(:user) { create(:user) }

  it 'enables users to login and logout' do
    log_in_as user, remember_me: '1'

    expect(page).to have_content(user.name_with_handle)
    expect(page).to have_link('Profile', href: user_path(user))
    expect(page).to have_link('Settings', href: edit_user_path(user))
    expect(page).to have_link('Log out', href: logout_path)
    expect(page).to have_link('Report')
    expect(page).not_to have_link('Log in', href: login_path)
    expect(user.reload.remember_digest).to be_present

    click_link 'Log out'

    expect(page).to have_link('Log in', href: login_path)
  end

  it 'enables users to redirect to the protected page after logging in (friendly forwarding)' do
    visit edit_user_path(user)

    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    within('form') do
      click_button t('views.sessions.log_in')
    end

    expect(page).to have_title('Settings')
  end
end
