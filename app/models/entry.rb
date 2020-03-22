class Entry < ApplicationRecord
  belongs_to :song
  belongs_to :member
  has_many :playable_times, -> { order(:range) }, dependent: :delete_all, inverse_of: :entry

  accepts_nested_attributes_for :playable_times, allow_destroy: true

  validates :playable_times, presence: true
  validates_associated :song
  validate :live_must_have_entry_guideline
  validate :live_must_be_entry_acceptable, on: :create
  validate :playable_time_on_live_day_exists, on: :create

  scope :submitted_or_played_by, ->(member) do
    left_joins(song: :plays).merge(Play.where(member_id: member.id)).or(left_joins(song: :plays).where(member_id: member.id)).distinct
  end

  def submitter?(user)
    member_id == user.member_id
  end

  def in_playable_time?
    if song.time.nil?
      playable_on_live_day?
    else
      playable_times.any? { |playable_time| playable_time.range.cover?(song.datetime) }
    end
  end

  def playable_time_sum
    playable_times.sum { |playable_time| playable_time.upper - playable_time.lower }
  end

  def as_json_for_notification
    as_json(
      only: %i[member_id notes],
      include: [
        { playable_times: { only: :range } },
        { song: { only: %i[live_id name artist original status comment], include: { plays: { only: %i[member_id instrument] } } } },
      ],
    )
  end

  private

  def playable_on_live_day?
    playable_times.any? { |playable_time| (song.live.date.beginning_of_day...song.live.date.end_of_day).overlaps?(playable_time.range) }
  end

  # region Validations

  def live_must_have_entry_guideline
    errors.add(:base, 'ライブはエントリー募集中ではありません') if song.live.entry_guideline.nil?
  end

  def live_must_be_entry_acceptable
    errors.add(:base, 'ライブのエントリー締切を過ぎています') if song.live.entry_guideline&.closed?
  end

  def playable_time_on_live_day_exists
    errors.add(:base, 'ライブ当日の演奏可能時間を入力してください') unless playable_on_live_day?
  end

  # endregion
end
