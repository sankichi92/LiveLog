class Live < ApplicationRecord
  has_many :songs, dependent: :restrict_with_exception

  validates :name, presence: true, length: { maximum: 20 }, uniqueness: { scope: :date }
  validates :date, presence: true
  validates :album_url, format: /\A#{URI.regexp(%w[http https])}\z/, allow_blank: true

  before_save :publish_past_live

  scope :newest_order, -> { order(date: :desc) }
  scope :nendo, ->(year) { where(date: Date.new(year, 4, 1)...Date.new(year + 1, 4, 1)) }
  scope :unpublished, -> { where(published: false) }
  scope :published, -> { where(published: true) }

  def self.years
    published.newest_order.pluck(:date).map(&:nendo).uniq
  end

  def title
    "#{date.year} #{name}"
  end

  def nf?
    name.include?('NF')
  end

  def publish!
    update!(published: true, published_at: Time.zone.now)
    songs.includes(:audio_attachment, :playings).import
  end

  private

  # region Callbacks

  def publish_past_live
    return if date >= Time.zone.today
    self.published = true
    self.published_at = Time.zone.now
  end

  # endregion
end
