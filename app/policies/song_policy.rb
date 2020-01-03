class SongPolicy < ApplicationPolicy
  def play?
    record.open? || record.closed? && logged_in? || record.player?(user&.member)
  end

  def update?
    user&.admin? || record.player?(user&.member)
  end
end
