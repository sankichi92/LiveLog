class Auth0Credential < ApplicationRecord
  SCOPES = %w[
    offline_access
    read:lives
    read:songs
  ].freeze

  belongs_to :user

  def save_with_omniauth_credentials!(credentials)
    self.access_token = credentials[:token]
    self.refresh_token = credentials[:refresh_token] if credentials[:refresh_token].present?
    self.expires_at = Time.zone.at(credentials[:expires_at])
    save!
  end
end
