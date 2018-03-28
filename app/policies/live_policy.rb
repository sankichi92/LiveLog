class LivePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if logged_in?
        scope.published
      else
        scope.all
      end
    end
  end

  def album?
    logged_in?
  end

  def create?
    user&.admin_or_elder?
  end

  def update?
    user&.admin_or_elder?
  end

  def destroy?
    user&.admin_or_elder?
  end
end
