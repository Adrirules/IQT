class OptionPolicy < ApplicationPolicy
  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    def resolve
      scope.all
      #scope.where(user: user)
    end
  end

  def new
    create?
  end
  def create?
    user_is_owner_of_question? || user.admin?
    #record.question.iqtest.user == user || user.admin?
  end
  def show?
    true
  end
  def update?
    record.question.iqtest.user == user || user.admin?
  end
  def destroy?
    record.question.iqtest.user == user || user.admin?
  end

    private

  def user_is_owner_of_question?
    record.question&.iqtest&.user == user || user.admin?
  end
end
