class SongPolicy < ApplicationPolicy
  def watch?
    record.open? || record.closed? && logged_in? || record.player?(user)
  end

  def create?
    user&.admin_or_elder?
  end

  def update?
    user&.admin_or_elder? || record.player?(user)
  end

  def destroy?
    user&.admin_or_elder?
  end
end
