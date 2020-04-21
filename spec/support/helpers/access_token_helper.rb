module AccessTokenHelper
  RSA_KEYPAIR = OpenSSL::PKey::RSA.new(512, 3).freeze
  DEFAULT_PAYLOAD = {
    iss: "https://#{Rails.application.config.x.auth0.domain}/",
    sub: 'auth0|0',
    aud: Rails.application.config.x.auth0.api_audience,
  }.freeze

  def stub_access_token(**payload)
    jwk = JWT::JWK.create_from(RSA_KEYPAIR)

    stub_request(:get, "https://#{Rails.application.config.x.auth0.domain}/.well-known/jwks.json").to_return(
      body: { keys: [jwk.export] }.to_json,
    )

    payload = DEFAULT_PAYLOAD.merge(iat: Time.zone.now.to_i, exp: 1.day.from_now.to_i).merge(payload)
    JWT.encode(payload, jwk.keypair, 'RS256', kid: jwk.kid)
  end
end
