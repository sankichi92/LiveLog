class Live < ApplicationRecord
  has_one :entry_guideline, dependent: :destroy
  has_many :songs, -> { played_order }, dependent: :restrict_with_exception, inverse_of: :live

  validates :date, presence: true
  validates :name, presence: true, length: { maximum: 20 }, uniqueness: { scope: :date }
  validates :place, length: { maximum: 20 }
  validates :album_url, format: /\A#{URI::DEFAULT_PARSER.make_regexp(%w[http https])}\z/, allow_blank: true
  validate :published_live_must_not_have_entry_guideline

  scope :newest_order, -> { order(date: :desc) }
  scope :nendo, ->(year) { where(date: Date.new(year, 4, 1)...Date.new(year + 1, 4, 1)) }
  scope :unpublished, -> { where(published: false) }
  scope :published, -> { where(published: true) }
  scope :entry_acceptable, -> { joins(:entry_guideline).merge(EntryGuideline.open) }

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
    transaction do
      Entry.joins(:song).merge(Song.where(live_id: id)).each(&:destroy!)
      entry_guideline&.destroy!
      update!(published: true, published_at: Time.zone.now)
    end

    songs.includes(:audio_attachment, :plays).import
  end

  def time_range
    if nf?
      date.in_time_zone.change(hour: 10)...date.in_time_zone.change(hour: 19)
    else
      date.in_time_zone.change(hour: 12)...date.in_time_zone.change(hour: 24)
    end
  end

  private

  # region Validations

  def published_live_must_not_have_entry_guideline
    errors.add(:base, 'エントリー募集中のライブは公開できません') if published? && entry_guideline && !entry_guideline.destroyed?
  end

  # endregion
end
