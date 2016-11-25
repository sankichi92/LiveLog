class Playing < ApplicationRecord
  belongs_to :user
  belongs_to :song
  validates :user_id, presence: true
  validates :song, presence: true
end
