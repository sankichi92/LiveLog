class Identity < ApplicationRecord
  belongs_to :user

  validates :user, presence: true
  validates :provider, presence: true, uniqueness: { scope: :user }
  validates :uid, presence: true, uniqueness: { scope: :provider }

  scope :google_oauth2, -> { where(provider: 'google_oauth2') }

  def self.find_with_omniauth(auth)
    find_by(uid: auth.uid, provider: auth.provider)
  end
end
