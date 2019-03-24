class GoogleCredential < ApplicationRecord
  belongs_to :user

  validates :user, presence: true
  validates :token, presence: true
  validates :refresh_token, presence: true
  validates :expires_at, presence: true

  def update_with_omniauth!(credentials)
    assign_attributes(
      token:         credentials.token,
      refresh_token: credentials.refresh_token,
      expires_at:    Time.at(credentials.expires_at),
    )
    save! if changed?
  end
end
