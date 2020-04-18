Rails.application.configure do
  config.x.auth0.client_id = ENV['AUTH0_CLIENT_ID']
  config.x.auth0.client_secret = ENV['AUTH0_CLIENT_SECRET']
  config.x.auth0.domain = ENV.fetch('AUTH0_DOMAIN', 'patient-bar-7812.auth0.com')
  config.x.auth0.api_audience = ENV.fetch('AUTH0_API_AUDIENCE', 'https://livelog.ku-unplugged.net/api/')
end
