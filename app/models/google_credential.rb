class GoogleCredential < ApplicationRecord
  belongs_to :user

  validates :user, presence: true
  validates :token, presence: true
  validates :expires_at, presence: true

  def update_with_omniauth!(credentials)
    self.token = credentials.token if credentials.token.present?
    self.refresh_token = credentials.refresh_token if credentials.refresh_token.present?
    self.expires_at = Time.at(credentials.expires_at) if credentials.expires_at.present?
    save! if changed?
  end
end
