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
    user&.admin_or_elder?
  end

  def update?
    record == user
  end

  def destroy?
    user&.admin_or_elder? && user != record
  end

  def invite?
    logged_in?
  end

  def change_status?
    user&.admin? && user != record
  end
end
