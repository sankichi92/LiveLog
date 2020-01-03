class Entry < ApplicationRecord
  belongs_to :song
  belongs_to :member
  has_many :available_times, dependent: :delete_all

  accepts_nested_attributes_for :available_times, allow_destroy: true

  validates :available_times, presence: true
  validates_associated :song
end
