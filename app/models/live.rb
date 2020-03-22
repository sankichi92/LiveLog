class Live < ApplicationRecord
  AlreadyPublishedError = Class.new(StandardError)

  has_one :entry_guideline, dependent: :destroy
  has_many :songs, dependent: :restrict_with_exception

  validates :date, presence: true
  validates :name, presence: true, length: { maximum: 20 }, uniqueness: { scope: :date }
  validates :place, length: { maximum: 20 }
  validates :album_url, format: /\A#{URI.regexp(%w[http https])}\z/, allow_blank: true

  scope :newest_order, -> { order(date: :desc) }
  scope :nendo, ->(year) { where(date: Date.new(year, 4, 1)...Date.new(year + 1, 4, 1)) }
  scope :unpublished, -> { where(published: false) }
  scope :published, -> { where(published: true) }

  def self.years
    newest_order.pluck(:date).map(&:nendo).uniq
  end

  def title
    "#{date.year} #{name}"
  end

  # For #collection_select option values
  def date_and_name
    "#{I18n.l(date)} #{name}"
  end

  def nf?
    name.include?('NF')
  end

  def publish!
    raise AlreadyPublishedError, "Live id #{id} has already been published" if published?

    update!(published: true, published_at: Time.zone.now)
    songs.includes(:audio_attachment, :plays).import
    Entry.joins(:song).merge(Song.where(live_id: id)).destroy_all
  end

  def time_range
    if nf?
      date.in_time_zone.change(hour: 10)...date.in_time_zone.change(hour: 19)
    else
      date.in_time_zone.change(hour: 12)...date.in_time_zone.change(hour: 24)
    end
  end
end
