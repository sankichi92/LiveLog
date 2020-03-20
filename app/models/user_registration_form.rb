class UserRegistrationForm < ApplicationRecord
  belongs_to :admin, class_name: 'User'

  attr_accessor :active_days

  validates :active_days, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 30 }

  before_create :set_token, :set_expires_at

  private

  # region Callbacks

  def set_token
    self.token ||= SecureRandom.base58
  end

  def set_expires_at
    self.expires_at ||= active_days.to_i.days.from_now
  end

  # endregion
end
