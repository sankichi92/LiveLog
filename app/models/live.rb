class Live < ApplicationRecord
  validates :name, presence: true, uniqueness: {scope: :date}
  validates :date, presence: true
end
