class AppAuth0Client
  include Singleton
  include Auth0::Mixins

  def initialize
    super(
      client_id: ENV['AUTH0_CLIENT_ID'],
      client_secret: ENV['AUTH0_CLIENT_SECRET'],
      domain: ENV.fetch('AUTH0_DOMAIN', 'patient-bar-7812.auth0.com'),
    )
  end
end
