require 'openid_config'

module JWTAuthentication
  extend ActiveSupport::Concern

  include ActionController::HttpAuthentication::Token::ControllerMethods

  included do
    before_action :authenticate_with_jwt
  end

  private

  def authenticate_with_jwt
    authenticate_or_request_with_http_token('LiveLog API') do |token, _options|
      openid_config = OpenIDConfig.new
      begin
        payload, _header = JWT.decode(
          token,
          nil,
          true,
          algorithms: openid_config.fetch(:id_token_signing_alg_values_supported),
          iss: openid_config.fetch(:issuer),
          aud: ENV.fetch('AUTH0_API_AUDIENCE', 'https://livelog.ku-unplugged.net/api/'),
          verify_iss: true,
          verify_aud: true,
          jwks: ->(_opts) { openid_config.get_jwks! },
        )
        @auth_payload = payload.with_indifferent_access
      rescue JWT::DecodeError => e
        Raven.capture_exception(e, level: :debug)
        false
      end
    end
  end

  def require_scope(scope)
    render status: :forbidden, json: { error: 'insufficient_scope' } if @auth_payload[:scope].nil? || !@auth_payload[:scope].split.include?(scope)
  end

  def current_user
    @current_user ||= if @auth_payload
                        User.find_by(auth0_id: @auth_payload.fetch(:sub))
                      else
                        nil
                      end
  end
end
