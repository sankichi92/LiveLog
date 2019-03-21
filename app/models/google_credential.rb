class GoogleCredential < ApplicationRecord
  belongs_to :user

  validates :user, presence: true
  validates :token, presence: true
  validates :refresh_token, presence: true
  validates :expires_at, presence: true
end
