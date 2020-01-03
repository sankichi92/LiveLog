class SongPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user&.admin?
        scope.all
      else
        scope.joins(:playings).merge(Playing.where(member_id: user&.member&.id))
      end
    end
  end

  def play?
    record.open? || record.closed? && logged_in? || record.player?(user&.member)
  end

  def update?
    user&.admin? || record.player?(user&.member)
  end
end
