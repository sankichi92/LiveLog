class Live < ApplicationRecord
  has_many :songs
  default_scope { order(date: :desc) }
  validates :name, presence: true, uniqueness: {scope: :date}
  validates :date, presence: true

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
