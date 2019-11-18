class Member < ApplicationRecord
  MINIMUM_JOINED_YEAR = 1995

  belongs_to :user, optional: true
  has_many :playings, dependent: :restrict_with_exception, foreign_key: :user_id, inverse_of: :member
  has_many :published_songs, -> { published }, through: :playings, source: :song

  has_one_attached :avatar

  validates :joined_year,
            presence: true,
            numericality: { only_integer: true, greater_than_or_equal_to: MINIMUM_JOINED_YEAR, less_than_or_equal_to: Time.zone.now.year }
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :nickname, length: { maximum: 50 }
  validates :url, format: { with: /\A#{URI::DEFAULT_PARSER.make_regexp(%w[http https])}\z/ }, allow_blank: true

  scope :regular_order, -> { order(joined_year: :desc, furigana: :asc) }
  scope :collaborated_with, ->(member) { joins(playings: :song).merge(member.published_songs).where.not(id: member.id) }
  scope :with_played_count, -> { joins(playings: :song).select('members.*', 'count(distinct songs.id) as played_count').group(:id).order('played_count desc') }

  def self.joined_years
    order(joined_year: :desc).distinct.pluck(:joined_year)
  end

  # region Names

  def full_name
    "#{last_name} #{first_name}"
  end

  def short_name
    nickname.presence || last_name
  end

  def long_name
    nickname.present? ? "#{full_name} (#{nickname})" : full_name
  end

  # endregion

  # region Aggregation Queries

  def played_instruments
    @played_instruments ||= playings.joins(song: :live).merge(Live.published).count_by_divided_instrument.keys
  end

  # endregion
end
