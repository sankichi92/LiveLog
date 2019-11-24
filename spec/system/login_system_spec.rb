require 'rails_helper'

RSpec.describe 'Login', type: :system do
  let(:user) { create(:user) }

  it 'enables users to login and logout' do
    log_in_as user, remember_me: true

    expect(page).not_to have_link('ログイン', href: login_path)
    expect(user.reload.remember_digest).to be_present

    click_link 'ログアウト'

    expect(page).to have_link('ログイン', href: login_path)
  end

  it 'enables users to redirect to the protected page after logging in (friendly forwarding)' do
    visit edit_user_path(user)

    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    within('form') do
      click_button 'ログインする'
    end

    expect(page).to have_title('メールアドレス設定')
  end
end
