class Entry < ApplicationRecord
  belongs_to :song
  belongs_to :member
  has_many :playable_times, -> { order(:range) }, dependent: :delete_all, inverse_of: :entry

  accepts_nested_attributes_for :playable_times, allow_destroy: true

  validates :playable_times, presence: true
  validates_associated :song
  validate :live_must_be_unpublished

  scope :submitted_or_played_by, ->(member) do
    left_joins(song: :plays).merge(Play.where(member_id: member.id)).or(left_joins(song: :plays).where(member_id: member.id)).distinct
  end

  def submitter?(user)
    member_id == user.member_id
  end

  def in_playable_time?
    if song.time.nil?
      playable_times.any? { |playable_time| (song.live.date.beginning_of_day...song.live.date.end_of_day).cover?(playable_time.range) }
    else
      playable_times.any? { |playable_time| playable_time.range.cover?(song.datetime) }
    end
  end

  def playable_time_sum
    playable_times.sum { |playable_time| playable_time.upper - playable_time.lower }
  end

  private

  # region Validations

  def live_must_be_unpublished
    errors.add(:base, 'エントリー募集中のライブではありません') if song.live.published?
  end

  # endregion
end
