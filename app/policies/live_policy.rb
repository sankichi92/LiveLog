class LivePolicy < ApplicationPolicy
  def album?
    logged_in?
  end

  def create?
    user&.admin?
  end

  def update?
    user&.admin?
  end

  def publish?
    user&.admin?
  end

  def destroy?
    user&.admin?
  end
end
