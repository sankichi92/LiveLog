Rails.application.config.middleware.use OmniAuth::Builder do
  provider :auth0,
           ENV['AUTH0_CLIENT_ID'],
           ENV['AUTH0_CLIENT_SECRET'],
           ENV['AUTH0_DOMAIN'],
           authorize_params: {
             audience: ENV['AUTH0_API_AUDIENCE'],
             scope: "openid email #{Auth0Credential::SCOPES.join(' ')}",
           }

  provider :github, ENV['GITHUB_CLIENT_ID'], ENV['GITHUB_CLIENT_SECRET']
end
