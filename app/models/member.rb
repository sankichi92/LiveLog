class Member < ApplicationRecord
  MINIMUM_JOINED_YEAR = 1995

  has_one :user, dependent: :restrict_with_exception
  has_many :plays, dependent: :restrict_with_exception
  has_many :published_songs, -> { published }, through: :plays, source: :song
  has_many :entries, dependent: :restrict_with_exception

  has_one_attached :avatar

  validates :joined_year,
            presence: true,
            numericality: { only_integer: true, greater_than_or_equal_to: MINIMUM_JOINED_YEAR, less_than_or_equal_to: Time.zone.now.year }
  validates :name, presence: true, length: { maximum: 20 }, uniqueness: { scope: :joined_year }
  validates :url, format: { with: /\A#{URI::DEFAULT_PARSER.make_regexp(%w[http https])}\z/ }, allow_blank: true
  validates :bio, length: { maximum: 200 }

  scope :regular_order, -> { order(joined_year: :desc, plays_count: :desc) }
  scope :collaborated_with, ->(member) { joins(plays: :song).merge(member.published_songs).where.not(id: member.id) }
  scope :with_played_count, -> { joins(plays: :song).select('members.*', 'count(distinct songs.id) as played_count').group(:id).order('played_count desc') }

  def self.joined_years
    order(joined_year: :desc).distinct.pluck(:joined_year)
  end

  # For #collection_select option values
  def joined_year_and_name
    "#{joined_year} #{name}"
  end

  def graduate?
    joined_year <= Time.zone.now.nendo - 4
  end

  def played_instruments
    @played_instruments ||= plays.joins(song: :live).merge(Live.published).count_by_divided_instrument.keys
  end
end
