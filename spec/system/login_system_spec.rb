require 'rails_helper'

RSpec.describe 'Login:', type: :system do
  specify 'A user is requested to log-in on a protected page, and after login, they are redirected to the protected page' do
    # Given
    user = create(:user)
    OmniAuth.config.mock_auth[:auth0] = OmniAuth::AuthHash.new(provide: 'auth0', uid: user.auth0_id)

    # When
    visit profile_path

    # Then
    expect(page).to have_content 'ログインしてください'
    expect(page).not_to have_title 'プロフィール設定'

    # When
    click_on 'ログイン'

    # Then
    expect(page).to have_content 'ログインしました'
    expect(page).to have_title 'プロフィール設定'
  end
end
