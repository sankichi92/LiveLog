class Live < ApplicationRecord
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
