module LoginRequestHelper
  def log_in_as(user)
    OmniAuth.config.mock_auth[:auth0] = OmniAuth::AuthHash.new(uid: user.auth0_id)
    get auth_auth0_callback_path
  end
end
