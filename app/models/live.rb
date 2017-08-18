class Live < ApplicationRecord
  has_many :songs, dependent: :restrict_with_exception

  scope :order_by_date, -> { order(date: :desc) }
  scope :future, -> { where('date > ?', Date.today) }

  validates :name, presence: true, uniqueness: { scope: :date }
  validates :date, presence: true
  validates :album_url, format: /\A#{URI.regexp(%w[http https])}\z/, allow_blank: true

  def self.years
    Live.order_by_date.select(:date).map(&:nendo).uniq
  end

  def title
    "#{date.year} #{name}"
  end

  def nendo
    if date.mon < 4
      date.year - 1
    else
      date.year
    end
  end
end
