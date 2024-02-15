class IqtestPolicy < ApplicationPolicy
  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    def resolve
      scope.all
      #scope.where(user: user)
    end
  end

  def create?
    true
  end
  def show?
    true
  end
  def update?
    record.user == user || user.admin?
  end
  def destroy?
    record.user == user || user.admin?
  end
end
