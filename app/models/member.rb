class Member < ApplicationRecord
  MINIMUM_JOINED_YEAR = 1994

  belongs_to :user, optional: true
  has_many :playings, dependent: :restrict_with_exception, foreign_key: :user_id, inverse_of: :member
  has_many :songs, through: :playings

  has_one_attached :avatar

  validates :joined_year,
            presence: true,
            numericality: { only_integer: true, greater_than_or_equal_to: MINIMUM_JOINED_YEAR, less_than_or_equal_to: Time.zone.now.year }
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :nickname, length: { maximum: 50 }
  validates :url, format: /\A#{URI.regexp(%w[http https])}\z/, allow_blank: true

  scope :regular_order, -> { order(joined_year: :desc, furigana: :asc) }

  def full_name
    "#{last_name} #{first_name}"
  end

  def short_name
    nickname.presence || last_name
  end

  def long_name
    nickname.present? ? "#{full_name} (#{nickname})" : full_name
  end
end
