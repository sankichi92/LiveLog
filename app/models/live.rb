class Live < ApplicationRecord
  has_many :songs, dependent: :restrict_with_exception
  scope :order_by_date, -> { order(date: :desc) }
  validates :name, presence: true, uniqueness: { scope: :date }
  validates :date, presence: true

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
