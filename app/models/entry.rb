class Entry < ApplicationRecord
  belongs_to :song
  belongs_to :member
  has_many :available_times, dependent: :delete_all
end
