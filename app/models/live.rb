class Live < ApplicationRecord
  has_many :songs, dependent: :restrict_with_exception

  validates :name, presence: true, uniqueness: { scope: :date }
  validates :date, presence: true
  validates :album_url, format: /\A#{URI.regexp(%w[http https])}\z/, allow_blank: true

  scope :order_by_date, -> { order(date: :desc) }
  scope :nendo, ->(year) { where(date: Date.new(year, 4, 1)...Date.new(year + 1, 4, 1)) }
  scope :draft, -> { where('date > ?', Time.zone.today) }
  scope :performed, -> { where('date <= ?', Time.zone.today) }

  def self.years
    Live.order_by_date.select(:date).map(&:nendo).uniq
  end

  def title
    "#{date.year} #{name}"
  end

  def nendo
    date.mon < 4 ? date.year - 1 : date.year
  end

  def draft?
    date > Time.zone.today
  end
end
