class PlayableTime < ApplicationRecord
  belongs_to :entry, touch: true

  validate :lower_must_be_less_than_upper

  scope :contains, ->(time) { where("#{table_name}.range @> ?::timestamp", time) }

  def lower=(time_str)
    self.range = time_str.to_s.in_time_zone...range&.last
  end

  def upper=(time_str)
    self.range = range&.first...time_str.to_s.in_time_zone
  end

  def lower
    range&.first
  end

  def upper
    range&.last
  end

  private

  # region Validations

  def lower_must_be_less_than_upper
    errors.add(:range, :invalid) unless lower < upper
  end

  # endregion
end
