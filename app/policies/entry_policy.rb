class EntryPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end
end
