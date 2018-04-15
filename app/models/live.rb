class Live < ApplicationRecord
  has_many :songs, dependent: :restrict_with_exception

  before_save :publish_past_live

  validates :name, presence: true, uniqueness: { scope: :date }
  validates :date, presence: true
  validates :album_url, format: /\A#{URI.regexp(%w[http https])}\z/, allow_blank: true

  scope :order_by_date, -> { order(date: :desc) }
  scope :nendo, ->(year) { where(date: Date.new(year, 4, 1)...Date.new(year + 1, 4, 1)) }
  scope :drafts, -> { where(published: false) }
  scope :published, -> { where(published: true) }
  scope :latest, -> { published.order_by_date.limit(5) }

  def self.years
    published.order_by_date.pluck(:date).map(&:nendo).uniq
  end

  def title
    "#{date.year} #{name}"
  end

  def nf?
    name.include?('NF')
  end

  def nendo
    date.nendo
  end

  def publish(url)
    update_columns(published: true, published_at: Time.zone.now)
    songs.includes(:'audio_attachment', :playings).import
    TweetJob.perform_now("#{title} のセットリストが公開されました！\n#{url}")
  end

  private

  def publish_past_live
    return if date >= Time.zone.today
    self.published = true
    self.published_at = Time.zone.now
  end
end
