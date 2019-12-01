module LoginSystemHelper
  def log_in_as(user)
    OmniAuth.config.mock_auth[:auth0] = OmniAuth::AuthHash.new(uid: user.auth0_id)
    visit root_path
    click_on 'ログイン'
  end
end
