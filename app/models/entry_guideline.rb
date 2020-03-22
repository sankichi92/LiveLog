class EntryGuideline < ApplicationRecord
  belongs_to :live

  validates :deadline, presence: true
  validate :live_must_be_unpublished
  validate :deadline_must_be_less_than_live_date

  scope :open, -> { where('deadline > ?', Time.zone.now) }

  def closed?
    !open?
  end

  def open?
    deadline.future?
  end

  private

  # region Validations

  def live_must_be_unpublished
    errors.add(:base, '公開済みのライブでエントリーの募集はできません') if live.published?
  end

  def deadline_must_be_less_than_live_date
    errors.add(:deadline, 'はライブ開催日より小さい値にしてください') if deadline && deadline > live.date.end_of_day
  end

  # endregion
end
