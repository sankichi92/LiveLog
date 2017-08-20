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
      )x

  belongs_to :live, touch: true
  has_many :playings, dependent: :destroy, inverse_of: :song
  accepts_nested_attributes_for :playings, allow_destroy: true

  attr_accessor :notes

  enum status: { secret: 0, closed: 1, open: 2 }

  before_save :extract_youtube_id

  validates :live_id, presence: true
  validates :name, presence: true
  validates :youtube_id, format: { with: VALID_YOUTUBE_REGEX }, allow_blank: true

  scope :played_order, -> { order(:time, :order) }
  scope :order_by_live, -> { includes(:live).order('lives.date DESC', :time, :order) }
  scope :visible, -> { where('lives.date < ?', Live.boundary_date) }

  def self.search(query, page)
    q = "%#{query}%"
    where('songs.name ILIKE ? OR artist ILIKE ?', q, q).order_by_live.paginate(page: page)
  end

  def extract_youtube_id
    return if youtube_id.blank?
    m = youtube_id.match(VALID_YOUTUBE_REGEX)
    self.youtube_id = m[:id]
  end

  def title
    artist.blank? ? name : "#{name} / #{artist}"
  end

  def youtube_url
    "https://www.youtube.com/watch?v=#{youtube_id}" if youtube_id.present?
  end

  def youtube_embed
    %(<iframe src="https://www.youtube.com/embed/#{youtube_id}?rel=0" frameborder="0" allowfullscreen></iframe>)
      .html_safe
  end

  def visible?(user)
    open? || closed? && user || user && user.played?(self)
  end

  def watchable?(user)
    youtube_id.present? && visible?(user)
  end

  def time_str
    time.strftime('%R') if time.present?
  end

  def time_order
    "#{time_str} #{order}"
  end

  def send_entry(applicant)
    SongMailer.entry(self, applicant).deliver_now
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
