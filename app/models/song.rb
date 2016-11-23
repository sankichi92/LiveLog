class Song < ApplicationRecord
  belongs_to :live
  default_scope { order(:order) }
  validates :live_id, presence: true
  validates :name, presence: true
end
