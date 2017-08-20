class Live < ApplicationRecord
  has_many :songs, dependent: :restrict_with_exception

  validates :name, presence: true, uniqueness: { scope: :date }
  validates :date, presence: true
  validates :album_url, format: /\A#{URI.regexp(%w[http https])}\z/, allow_blank: true

  scope :order_by_date, -> { order(date: :desc) }
  scope :future, -> { where('date >= ?', boundary_date) }
  scope :visible, -> { where('date < ?', boundary_date) }

  def self.years
    Live.order_by_date.select(:date).map(&:nendo).uniq
  end

  def self.boundary_date
    Date.today + 1.week
  end

  def title
    "#{date.year} #{name}"
  end

  def nendo
    date.mon < 4 ? date.year - 1 : date.year
  end

  def future?
    date >= Live.boundary_date
  end
end
