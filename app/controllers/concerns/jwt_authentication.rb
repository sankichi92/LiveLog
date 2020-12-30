# frozen_string_literal: true

module JWTAuthentication
  extend ActiveSupport::Concern

  include ActionController::HttpAuthentication::Token::ControllerMethods

  attr_reader :auth_payload

  included do
    before_action :authenticate_with_jwt
  end

  private

  def authenticate_with_jwt
    authenticate_or_request_with_http_token('LiveLog API') do |token, _options|
      payload, _header = JWT.decode(
        token,
        nil,
        true,
        algorithm: 'RS256',
        iss: "https://#{Rails.application.config.x.auth0.domain}/",
        aud: Rails.application.config.x.auth0.api_audience,
        verify_iss: true,
        verify_aud: true,
        jwks: lambda do |_opts|
          jwks_uri = URI.parse("https://#{Rails.application.config.x.auth0.domain}/.well-known/jwks.json")
          response = Net::HTTP.get_response(jwks_uri)
          JSON.parse(response.body, symbolize_names: true)
        end,
      )
      @auth_payload = payload.symbolize_keys
    rescue JWT::DecodeError => e
      Sentry.capture_exception(e, level: :debug)
      false
    end
  end

  def current_user
    @current_user ||= if auth_payload && auth_payload[:gty] != 'client-credentials'
                        User.find_by(auth0_id: auth_payload.fetch(:sub))
                      end
  end

  def current_client
    @current_client ||= if auth_payload && auth_payload[:azp]
                          Client.find_by(auth0_id: auth_payload[:azp])
                        end
  end

  # region Filters

  def require_scope(scope)
    render status: :forbidden, json: { errors: [{ message: 'Insufficient scope' }] } if auth_payload[:scope].nil? || auth_payload[:scope].split.exclude?(scope)
  end

  # endregion
end
