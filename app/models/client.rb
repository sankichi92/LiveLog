require 'app_auth0_client'

class Client < ApplicationRecord
  APP_TYPES = %w[native spa regular_web non_interactive].freeze

  AlreadyCreatedError = Class.new(StandardError)

  belongs_to :developer

  attr_accessor :app_type

  validates :name, presence: true
  validates :app_type, presence: true, inclusion: { in: APP_TYPES }, on: :create
  validates :url, format: { with: /\A#{URI::DEFAULT_PARSER.make_regexp(%w[http https])}\z/ }, allow_blank: true

  def create_auth0_client!
    raise AlreadyCreatedError, "Auth0 Client is already created: #{auth0_id}" if auth0_id.present?

    validate!(:create)
    self.logo_url = developer.avatar_url

    client = AppAuth0Client.instance.create_client(name, logo_uri: logo_url, app_type: app_type)
    update!(auth0_id: client.fetch('client_id'))
  end

  def create_livelog_grant!
    raise AlreadyCreatedError, "Grant for LiveLog is already created: #{livelog_grant_id}" if livelog_grant_id.present?

    grant = AppAuth0Client.instance.create_client_grant(client_id: auth0_id, audience: Rails.application.config.x.auth0.api_audience, scope: [])
    update!(livelog_grant_id: grant.fetch('id'))
  end
end
