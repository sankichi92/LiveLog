require 'app_auth0_client'

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

  def valid_access_token
    if expired?
      if refresh_token.present?
        refresh!
        access_token
      else
        nil
      end
    else
      access_token
    end
  end

  def expired?
    expires_at.past?
  end

  def refresh!
    auth0_access_token = AppAuth0Client.instance.exchange_refresh_token(refresh_token)

    self.access_token = auth0_access_token.token
    self.refresh_token = auth0_access_token.refresh_token if auth0_access_token.refresh_token.present?
    self.expires_at = auth0_access_token.expires_in.seconds.from_now
    save!
  end
end
