class Song < ApplicationRecord
  has_many :playings, dependent: :destroy, inverse_of: :song
  has_many :users, through: :playings
  belongs_to :live
  accepts_nested_attributes_for :playings, allow_destroy: true
  default_scope { includes(:live).order('lives.date DESC', :time, :order) }
  validates :live_id, presence: true
  validates :name, presence: true
  VALID_YOUTUBE_REGEX =
      %r(\A
         (?:
          (?<id>\S{11})\z
          |(?:https?://)?
           (?:www\.youtube\.com/watch\?(?:\S*&)*v=
            |youtu\.be/)
           (?<id>\S{11})
         )
        )x
  validates :youtube_id, format: {with: VALID_YOUTUBE_REGEX}, allow_blank: true
  before_save :extract_youtube_id
  enum status: {
      secret: 0,
      closed: 1,
      open: 2
  }

  def Song.search(query, page) # TODO: Improve
    q = "%#{query}%"
    where('songs.name ILIKE ? OR artist ILIKE ?', q, q).paginate(page: page)
  end

  def extract_youtube_id
    unless youtube_id.blank?
      m = youtube_id.match(VALID_YOUTUBE_REGEX)
      self.youtube_id = m[:id]
    end
  end

  def title
    artist.blank? ? name : "#{name} / #{artist}"
  end

  def youtube_url
    "https://www.youtube.com/watch?v=#{youtube_id}" unless youtube_id.blank?
  end

  def youtube_embed
    %(<iframe src="https://www.youtube.com/embed/#{youtube_id}?rel=0" frameborder="0" allowfullscreen></iframe>).html_safe
  end

  def time_str
    time.strftime('%R') unless time.blank?
  end

  def time_order
    "#{time_str} #{order}"
  end

  def previous
    Song.where('lives.id = ? AND (songs.order < ? OR songs.time < ?)', live.id, order, time).last unless order.blank?
  end

  def next
    Song.where('lives.id = ? AND (songs.order > ? OR songs.time > ?)', live.id, order, time).first unless order.blank?
  end
end
