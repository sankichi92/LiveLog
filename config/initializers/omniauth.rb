Rails.application.config.middleware.use OmniAuth::Builder do
  provider :auth0,
           ENV['AUTH0_CLIENT_ID'],
           ENV['AUTH0_CLIENT_SECRET'],
           ENV['AUTH0_DOMAIN'],
           authorize_params: { scope: 'openid email profile' }
end
