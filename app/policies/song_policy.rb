class SongPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user&.admin?
        scope.all
      else
        scope.joins(:playings).where('playings.member_id': user&.member&.id)
      end
    end
  end

  def play?
    record.open? || record.closed? && logged_in? || record.player?(user&.member)
  end

  def create?
    user&.admin_or_elder?
  end

  def update?
    user&.admin_or_elder? || record.player?(user&.member)
  end

  def destroy?
    user&.admin_or_elder?
  end
end
