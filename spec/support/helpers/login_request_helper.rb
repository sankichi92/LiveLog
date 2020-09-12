# frozen_string_literal: true

module LoginRequestHelper
  def log_in_as(user)
    OmniAuth.config.mock_auth[:auth0] = OmniAuth::AuthHash.new(
      uid: user.auth0_id,
      credentials: {
        token: 'access_token',
        expires_at: 1.day.from_now.to_i,
        refresh_token: nil,
      },
      extra: {
        raw_info: {
          name: user.member.name,
          email: user.email,
          email_verified: true,
        },
      },
    )
    get auth_auth0_callback_path
  end
end
