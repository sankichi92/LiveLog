class PlayableTime < ApplicationRecord
  belongs_to :entry, touch: true

  validate :lower_must_be_less_than_upper

  before_save :assign_range

  def lower=(time_str)
    @lower = time_str.to_s.in_time_zone
  end

  def upper=(time_str)
    @upper = time_str.to_s.in_time_zone
  end

  def lower
    @lower ||= range&.first || Time.zone.now.beginning_of_hour
  end

  def upper
    @upper ||= range&.last || 1.hour.from_now.beginning_of_hour
  end

  private

  # region Validations

  def lower_must_be_less_than_upper
    errors.add(:range, :invalid) unless lower < upper
  end

  # endregion

  # region Callbacks

  def assign_range
    self.range = lower...upper
  end

  # endregion
end
