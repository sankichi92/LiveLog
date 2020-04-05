class AppAuth0Client
  include Singleton
  include Auth0::Mixins

  def initialize
    super(
      client_id: ENV.fetch('AUTH0_CLIENT_ID'),
      client_secret: ENV.fetch('AUTH0_CLIENT_SECRET'),
      domain: ENV.fetch('AUTH0_DOMAIN'),
    )
  end
end
