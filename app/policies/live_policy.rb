class LivePolicy < ApplicationPolicy
  def album?
    logged_in?
  end

  def create?
    user&.admin_or_elder?
  end

  def update?
    user&.admin_or_elder?
  end

  def publish?
    user&.admin?
  end

  def destroy?
    user&.admin_or_elder?
  end
end
