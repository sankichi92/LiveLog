class Song < ApplicationRecord
  VALID_YOUTUBE_REGEX =
    %r(\A
       (?:
        (?<id>\S{11})\z
        |(?:https?://)?
         (?:www\.youtube\.com/watch\?(?:\S*&)*v=
          |youtu\.be/)
         (?<id>\S{11})
       )
      )x.freeze

  include SongSearchable

  belongs_to :live
  has_many :playings, dependent: :destroy, inverse_of: :song
  has_many :members, through: :playings

  accepts_nested_attributes_for :playings, allow_destroy: true

  has_one_attached :audio

  enum status: { secret: 0, closed: 1, open: 2 }

  before_save :extract_youtube_id

  validates :live_id, presence: true
  validates :name, presence: true
  validates :youtube_id, format: { with: VALID_YOUTUBE_REGEX }, allow_blank: true

  scope :played_order, -> { order(:time, :order) }
  scope :newest_live_order, -> { joins(:live).order('lives.date desc', :time, :order) }
  scope :published, -> { joins(:live).merge(Live.published) }

  self.per_page = 20

  def self.pickup(date: Time.zone.today)
    song_id = Rails.cache.fetch("#{name.underscore}/pickup/#{date}/song_id", expires_in: 1.day) do
      random = Random.new(date.to_time.to_i)
      candidate_songs = joins(:live).merge(Live.published.where('date < ?', date)).where.not(status: :secret)
      count = candidate_songs.count
      candidate_songs.offset(random.rand(count)).first.id if count.positive?
    end
    find_by(id: song_id)
  end

  def self.artists_for_suggestion
    where.not(artist: '').group(:artist).order(count_all: :desc).having('count(*) >= 2').count.keys
  end

  def title
    artist.blank? ? name : "#{name} / #{artist}"
  end

  def datetime
    return live.date if time.blank?
    live.date + time.hour.hours + time.min.minutes
  end

  def time_str
    time&.strftime('%R')
  end

  def player?(member)
    playings.map(&:member_id).include?(member&.id)
  end

  private

  def extract_youtube_id
    return if youtube_id.blank?
    m = youtube_id.match(VALID_YOUTUBE_REGEX)
    self.youtube_id = m[:id]
  end
end
