class Song < ApplicationRecord
  include Concerns::Song::Searchable

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

  delegate :title, :name, to: :live, prefix: true
  delegate :date, :published?, :nf?, to: :live
  delegate :size, to: :playings, prefix: true

  enum status: { secret: 0, closed: 1, open: 2 }

  before_save :extract_youtube_id

  validates :live_id, presence: true
  validates :name, presence: true
  validates :youtube_id, format: { with: VALID_YOUTUBE_REGEX }, allow_blank: true

  scope :played_order, -> { order(:time, :order) }
  scope :order_by_live, -> { includes(:live).order('lives.date DESC', :time, :order) }
  scope :published, -> { eager_load(:live).where('lives.published': true) }

  def self.pickup(date = Time.zone.today)
    random = Random.new(date.to_time.to_i)
    songs = eager_load(:live).where('lives.date <= ?', date).where.not(youtube_id: '', status: :secret)
    songs.offset(random.rand(songs.count)).first if songs.exists?
  end

  def title
    artist.blank? ? name : "#{name} / #{artist}"
  end

  def youtube_url
    "https://www.youtube.com/watch?v=#{youtube_id}" if youtube_id.present?
  end

  def visible?(user)
    open? || closed? && user || user && user.played?(self)
  end

  def watchable?(user)
    youtube_id.present? && visible?(user)
  end

  def editable?(user)
    user.present? && (user.admin_or_elder? || user.played?(self))
  end

  def datetime
    return date if time.blank?
    date + time.hour.hours + time.min.minutes
  end

  def time_str
    time.strftime('%R') if time.present?
  end

  def time_order
    "#{time_str} #{order}"
  end

  def add_error_for_duplicated_user
    errors.add(:playings, 'が重複しています')
  end

  private

  def extract_youtube_id
    return if youtube_id.blank?
    m = youtube_id.match(VALID_YOUTUBE_REGEX)
    self.youtube_id = m[:id]
  end
end
