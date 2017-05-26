class Song < ApplicationRecord
  has_many :playings, dependent: :destroy, inverse_of: :song
  has_many :users, through: :playings
  belongs_to :live
  accepts_nested_attributes_for :playings, allow_destroy: true
  scope :played_order, -> { order(:time, :order) }
  scope :order_by_live, lambda {
    includes(:live).order('lives.date DESC', :time, :order)
  }
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
  validates :youtube_id,
            format:      { with: VALID_YOUTUBE_REGEX },
            allow_blank: true
  before_save :extract_youtube_id
  enum status: {
    secret: 0,
    closed: 1,
    open:   2
  }

  def self.search(query, page) # TODO: Improve
    q = "%#{query}%"
    order_by_live
      .where('songs.name ILIKE ? OR artist ILIKE ?', q, q)
      .paginate(page: page)
  end

  def extract_youtube_id
    return if youtube_id.blank?
    m               = youtube_id.match(VALID_YOUTUBE_REGEX)
    self.youtube_id = m[:id]
  end

  def title
    artist.blank? ? name : "#{name} / #{artist}"
  end

  def youtube_url
    "https://www.youtube.com/watch?v=#{youtube_id}" unless youtube_id.blank?
  end

  def youtube_embed
    %(<iframe src="https://www.youtube.com/embed/#{youtube_id}?rel=0" frameborder="0" allowfullscreen></iframe>)
      .html_safe
  end

  def time_str
    time.strftime('%R') unless time.blank?
  end

  def time_order
    "#{time_str} #{order}"
  end

  def previous(logged_in = false)
    return nil if order.blank?
    allowed_statuses = if logged_in
                         [Song.statuses[:open], Song.statuses[:closed]]
                       else
                         [Song.statuses[:open]]
                       end
    Song
      .where(live: live, status: allowed_statuses)
      .where("(songs.order < ? OR songs.time < ?) AND NOT (songs.youtube_id IS NULL OR songs.youtube_id = '')", order, time)
      .last
  end

  def next(logged_in = false)
    return nil if order.blank?
    allowed_statuses = if logged_in
                         [Song.statuses[:open], Song.statuses[:closed]]
                       else
                         [Song.statuses[:open]]
                       end
    Song
      .where(live: live, status: allowed_statuses)
      .where("(songs.order > ? OR songs.time > ?) AND NOT (songs.youtube_id IS NULL OR songs.youtube_id = '')", order, time)
      .first
  end
end
