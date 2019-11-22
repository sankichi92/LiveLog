class UserPolicy < ApplicationPolicy
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
