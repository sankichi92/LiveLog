class UserPolicy < ApplicationPolicy
  def create?
    user&.admin?
  end

  def update?
    record == user
  end

  def destroy?
    user&.admin? && user != record
  end

  def change_status?
    user&.admin? && user != record
  end
end
