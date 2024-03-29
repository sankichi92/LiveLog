# frozen_string_literal: true

require 'livelog/auth0_client'

class Client < ApplicationRecord
  APP_TYPES = %w[native spa regular_web non_interactive].freeze
  JWT_SIGNATURE_ALGORITHMS = %w[HS256 RS256].freeze
  DEFAULT_FIELDS = %w[
    client_secret
    app_type
    callbacks
    initiate_login_uri
    allowed_logout_urls
    web_origins
    jwt_configuration.alg
  ].freeze

  AlreadyCreatedError = Class.new(StandardError)

  belongs_to :developer

  attr_writer :app_type, :callback_url, :login_url, :logout_url, :web_origin, :jwt_signature_alg

  validates :name, presence: true
  validates :description, length: { maximum: 140 }
  validates :logo_url, format: { with: /\A#{URI::DEFAULT_PARSER.make_regexp(%w[http https])}\z/ }
  validates :app_type, presence: true, inclusion: { in: APP_TYPES }
  validates :jwt_signature_alg, inclusion: { in: JWT_SIGNATURE_ALGORITHMS }, allow_blank: true

  def create_auth0_client!
    raise AlreadyCreatedError, "Auth0 Client is already created: #{auth0_id}" if auth0_id.present?

    validate!

    @info = LiveLog::Auth0Client.instance.create_client(
      name,
      logo_uri: logo_url,
      app_type:,
      grant_types: %w[authorization_code refresh_token client_credentials],
      oidc_conformant: true,
    )
    update!(auth0_id: @info.fetch('client_id'))
  end

  def create_livelog_grant!
    raise AlreadyCreatedError, "Grant for LiveLog is already created: #{livelog_grant_id}" if livelog_grant_id.present?

    grant = LiveLog::Auth0Client.instance.create_client_grant(client_id: auth0_id, audience: Rails.application.config.x.auth0.api_audience, scope: [])
    update!(livelog_grant_id: grant.fetch('id'))
  end

  def update_auth0_client
    @info = LiveLog::Auth0Client.instance.patch_client(
      auth0_id,
      {
        name:,
        description:,
        logo_uri: logo_url,
        app_type:,
        callbacks: [callback_url.presence].compact,
        initiate_login_uri: login_url,
        allowed_logout_urls: [logout_url.presence].compact,
        web_origins: [web_origin.presence].compact,
        jwt_configuration: {
          alg: jwt_signature_alg,
        },
      },
    )
  rescue Auth0::BadRequest => e
    Sentry.capture_exception(e, level: :debug)
    errors.add(:base, JSON.parse(e.message)['message'])
    false
  end

  def destroy_with_auth0_client!
    LiveLog::Auth0Client.instance.delete_client(auth0_id)
    destroy!
  end

  def client_secret
    info['client_secret']
  end

  def app_type
    @app_type ||= info['app_type']
  end

  def callback_url
    @callback_url ||= info['callbacks']&.first
  end

  def login_url
    @login_url ||= info['initiate_login_uri']
  end

  def logout_url
    @logout_url ||= info['allowed_logout_urls']&.first
  end

  def web_origin
    @web_origin ||= info['web_origins']&.first
  end

  def jwt_signature_alg
    @jwt_signature_alg ||= info.dig('jwt_configuration', 'alg')
  end

  def info(fields: DEFAULT_FIELDS)
    if auth0_id.present?
      @info ||= LiveLog::Auth0Client.instance.client(auth0_id, fields: fields.join(','))
    else
      {}
    end
  end
end
