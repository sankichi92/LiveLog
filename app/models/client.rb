require 'app_auth0_client'

class Client < ApplicationRecord
  APP_TYPES = %w[native spa regular_web non_interactive].freeze
  DEFAULT_FIELDS = %w[
    client_secret
    app_type
    callbacks
    initiate_login_uri
    allowed_logout_urls
    allowed_origins
  ].freeze

  AlreadyCreatedError = Class.new(StandardError)

  belongs_to :developer

  attr_writer :app_type, :callback_url, :login_url, :logout_url, :allowed_origin

  validates :name, presence: true
  validates :description, length: { maximum: 140 }
  validates :logo_url, format: { with: /\A#{URI::DEFAULT_PARSER.make_regexp(%w[http https])}\z/ }, allow_blank: true
  validates :url, format: { with: /\A#{URI::DEFAULT_PARSER.make_regexp(%w[http https])}\z/ }, allow_blank: true
  validates :app_type, presence: true, inclusion: { in: APP_TYPES }

  def create_auth0_client!
    raise AlreadyCreatedError, "Auth0 Client is already created: #{auth0_id}" if auth0_id.present?

    validate!(:create)
    self.logo_url = developer.avatar_url

    @info = AppAuth0Client.instance.create_client(name, logo_uri: logo_url, app_type: app_type, oidc_conformant: true)
    update!(auth0_id: @info.fetch('client_id'))
  end

  def create_livelog_grant!
    raise AlreadyCreatedError, "Grant for LiveLog is already created: #{livelog_grant_id}" if livelog_grant_id.present?

    grant = AppAuth0Client.instance.create_client_grant(client_id: auth0_id, audience: Rails.application.config.x.auth0.api_audience, scope: [])
    update!(livelog_grant_id: grant.fetch('id'))
  end

  def update_auth0_client!
    @info = AppAuth0Client.instance.patch_client(
      auth0_id,
      {
        name: name,
        description: description,
        logo_uri: logo_url,
        app_type: app_type,
        callbacks: [callback_url.presence].compact,
        initiate_login_uri: login_url,
        allowed_logout_urls: [logout_url.presence].compact,
        allowed_origins: [allowed_origin.presence].compact,
      },
    )
  rescue Auth0::BadRequest => e
    Raven.capture_exception(e, level: :debug)
    errors.add(:base, JSON.parse(e.message)['message'])
    false
  end

  def destroy_with_auth0_client!
    AppAuth0Client.instance.delete_client(auth0_id)
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

  def allowed_origin
    @allowed_origin ||= info['allowed_origins']&.first
  end

  def info(fields: DEFAULT_FIELDS)
    if auth0_id.present?
      @info ||= AppAuth0Client.instance.client(auth0_id, fields: fields.join(','))
    else
      {}
    end
  end
end
