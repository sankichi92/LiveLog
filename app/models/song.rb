class Song < ApplicationRecord
  belongs_to :live
  validates :live_id, presence: true
end
