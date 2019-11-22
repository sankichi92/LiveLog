class UserPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if !user.nil?
        scope.all
      else
        scope.where(public: true)
      end
    end
  end

  def show?
    logged_in? || record.public?
  end

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
