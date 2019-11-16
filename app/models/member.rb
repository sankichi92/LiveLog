class Member < ApplicationRecord
  MINIMUM_JOINED_YEAR = 1994

  belongs_to :user, optional: true

  validates :joined_year,
            presence: true,
            numericality: { only_integer: true, greater_than_or_equal_to: MINIMUM_JOINED_YEAR, less_than_or_equal_to: Time.zone.now.year }
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :nickname, length: { maximum: 50 }
  validates :url, format: /\A#{URI.regexp(%w[http https])}\z/, allow_blank: true
end
