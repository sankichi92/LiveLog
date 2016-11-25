class Playing < ApplicationRecord
  belongs_to :user
  belongs_to :song
  before_save :remove_dot
  validates :user_id, presence: true
  validates :song, presence: true

  def remove_dot
    unless inst.blank?
      self.inst = inst.gsub(/\s+/, '')
      self.inst.chop if inst.last == '.'
    end
  end
end
