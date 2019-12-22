class Member < ApplicationRecord
  MINIMUM_JOINED_YEAR = 1995
  MAXIMUM_NAME_LENGTH = 20

  has_one :user, dependent: :restrict_with_error
  has_many :playings, dependent: :restrict_with_error
  has_many :published_songs, -> { published }, through: :playings, source: :song

  has_one_attached :avatar

  validates :joined_year,
            presence: true,
            numericality: { only_integer: true, greater_than_or_equal_to: MINIMUM_JOINED_YEAR, less_than_or_equal_to: Time.zone.now.year }
  validates :name, presence: true, length: { maximum: MAXIMUM_NAME_LENGTH }, uniqueness: { scope: :joined_year }
  validates :url, format: { with: /\A#{URI::DEFAULT_PARSER.make_regexp(%w[http https])}\z/ }, allow_blank: true
  validates :bio, length: { maximum: 200 }

  scope :regular_order, -> { order(joined_year: :desc, playings_count: :desc) }
  scope :collaborated_with, ->(member) { joins(playings: :song).merge(member.published_songs).where.not(id: member.id) }
  scope :with_played_count, -> { joins(playings: :song).select('members.*', 'count(distinct songs.id) as played_count').group(:id).order('played_count desc') }

  def self.joined_years
    order(joined_year: :desc).distinct.pluck(:joined_year)
  end

  # region Attributes

  # For #collection_select option values
  def joined_year_and_name
    "#{joined_year} #{name}"
  end

  # endregion

  # region Status

  def graduate?
    joined_year <= Time.zone.now.nendo - 4
  end

  # endregion

  # region Aggregation Queries

  def played_instruments
    @played_instruments ||= playings.joins(song: :live).merge(Live.published).count_by_divided_instrument.keys
  end

  # endregion
end
