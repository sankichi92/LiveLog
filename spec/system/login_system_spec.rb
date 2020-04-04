require 'rails_helper'

RSpec.describe 'Login:', type: :system do
  specify 'A user is requested to log-in on a protected page, and after login, they are redirected to the protected page' do
    # Given
    user = create(:user)
    OmniAuth.config.mock_auth[:auth0] = OmniAuth::AuthHash.new(
      provide: 'auth0',
      uid: user.auth0_id,
      credentials: {
        token: 'access_token',
        expires_at: 1.day.from_now.to_i,
        refresh_token: 'refresh_token',
      },
      extra: {
        raw_info: {
          name: user.member.name,
          email: user.email,
          email_verified: true,
        },
      },
    )

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
