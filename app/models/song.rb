# frozen_string_literal: true

class Song < ApplicationRecord
  include SongSearchable

  belongs_to :live, counter_cache: true
  has_many :plays, dependent: :destroy
  has_many :members, through: :plays
  has_one :entry, dependent: :destroy
  has_one_attached :audio

  accepts_nested_attributes_for :plays, allow_destroy: true

  acts_as_list scope: :live

  enum :visibility, { only_players: 0, only_logged_in_users: 1, open: 2 }, prefix: true, scopes: false

  validates :name, presence: true
  validates :position, presence: true, on: :update
  validate :unique_players

  scope :played_order, -> { order(:time, :position) }
  scope :newest_live_order, -> { joins(:live).order('lives.date desc', :time, :position) }
  scope :published, -> { joins(:live).merge(Live.published) }

  def self.pickup(date: Time.zone.today)
    song_id = Rails.cache.fetch("#{model_name.cache_key}/pickup/#{date}/song_id", expires_in: 1.day) do
      random = Random.new(date.to_time.to_i)
      candidate_songs = joins(:live).merge(Live.published.where(date: ...date)).where.not(visibility: :only_players)
      count = candidate_songs.count
      candidate_songs.offset(random.rand(count)).pick(:id) if count.positive?
    end
    find_by(id: song_id)
  end

  def self.artists_for_suggestion
    where.not(artist: '').group(:artist).order(count_all: :desc).having('count(*) >= 2').count.keys
  end

  def title
    if artist.present?
      "#{name} / #{artist}"
    else
      name
    end
  end

  def datetime
    if time.nil?
      live.date.in_time_zone
    else
      live.date.in_time_zone.change(hour: time.hour, min: time.min)
    end
  end

  def time_str
    time&.strftime('%R')
  end

  def youtube_url=(url_str)
    uri = URI.parse(url_str.to_s)
    self.youtube_id = case uri.host
                      when 'www.youtube.com'
                        Rack::Utils.parse_query(uri.query)['v']
                      when 'youtu.be'
                        uri.path[1..]
                      end
  end

  def youtube_url
    if youtube_id.present?
      "https://www.youtube.com/watch?v=#{youtube_id}"
    else
      ''
    end
  end

  def player?(member)
    plays.map(&:member_id).include?(member&.id)
  end

  def previous
    live.songs.where('songs.time < ? or songs.position < ?', time, position).last
  end

  def next
    live.songs.where('songs.time > ? or songs.position > ?', time, position).first
  end

  private

  # region Validations

  # FIXME: https://github.com/sankichi92/LiveLog/issues/118
  def unique_players
    errors.add(:plays, 'が重複しています') if plays.map(&:member_id).uniq!
  end

  # endregion
end
