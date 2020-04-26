require 'app_auth0_client'

module Auth0ClientHelper
  def stub_auth0_client(client, fields: Client::DEFAULT_FIELDS)
    allow(auth0_client_double).to receive(:client).with(
      client.auth0_id,
      fields: fields.join(','),
    ).and_return(
      {
        tenant: Rails.application.config.x.auth0.domain,
        client_id: client.auth0_id,
        client_secret: 'auth0_client_secret',
        name: client.name,
        description: client.description,
        logo_uri: client.logo_url,
        app_type: client.app_type,
        callbacks: nil,
        initiate_login_uri: nil,
        allowed_logout_urls: nil,
        web_origins: nil,
      }.compact.stringify_keys.slice(*fields),
    )
  end

  def auth0_client_double
    @auth0_client_double ||= double(:auth0_client).tap do |auth0_client|
      allow(AppAuth0Client).to receive(:instance).and_return(auth0_client)
    end
  end
end
