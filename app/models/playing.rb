class Playing < ApplicationRecord
  belongs_to :user_id
  belongs_to :song_id
end
