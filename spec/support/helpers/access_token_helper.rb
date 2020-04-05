module AccessTokenHelper
  ISSUER = 'https://example.com/'.freeze
  RSA_KEYPAIR = OpenSSL::PKey::RSA.new(512, 3).freeze
  DEFAULT_PAYLOAD = {
    iss: ISSUER,
    sub: 'auth0|0',
    aud: ENV.fetch('AUTH0_API_AUDIENCE', 'https://livelog.ku-unplugged.net/api/'),
  }.freeze

  def stub_access_token(**payload)
    jwk = JWT::JWK.create_from(RSA_KEYPAIR)
    jwks_uri = 'http://example.com/.well-known/jwks.json'
    stub_request(:get, "https://#{ENV.fetch('AUTH0_DOMAIN', 'patient-bar-7812.auth0.com')}/.well-known/openid-configuration").to_return(
      body: {
        issuer: ISSUER,
        jwks_uri: jwks_uri,
        id_token_signing_alg_values_supported: %w[RS256],
      }.to_json,
    )
    stub_request(:get, jwks_uri).to_return(
      body: {
        keys: [jwk.export],
      }.to_json,
    )

    payload = DEFAULT_PAYLOAD.merge(iat: Time.zone.now.to_i, exp: 1.day.from_now.to_i).merge(payload)
    JWT.encode(payload, jwk.keypair, 'RS256', kid: jwk.kid)
  end
end
