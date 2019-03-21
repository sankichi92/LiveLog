class Identity < ApplicationRecord
  belongs_to :user

  validates :user, presence: true
  validates :provider, presence: true, uniqueness: { scope: :user }
  validates :uid, presence: true, uniqueness: { scope: :provider }
end
