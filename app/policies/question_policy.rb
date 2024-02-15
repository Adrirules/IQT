class QuestionPolicy < ApplicationPolicy
  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    def resolve
      scope.all
      #scope.where(user: user)
    end
  end

  def create?
    iqtest = record&.iqtest
    iqtest.present? && (iqtest.user == user || user.admin?)

    #iqtest = record.first&.iqtest
    #record.iqtest.present? && record.iqtest.user == user || user.admin?
    #true
  end

  def new?
    create?
  end
  def show?
    true
  end
  def update?
    #iqtest = record.first&.iqtest
    #record.iqtest.user == user || user.admin?
    iqtest = record.iqtest
    iqtest.user == user || user.admin?
  end
  def destroy?
    #record.first&.iqtest&.user == user || user.admin?
    #record.iqtest.user == user || user.admin?
    #record.iqtest&.user == user || user.admin?
    record && (record.iqtest.user == user || user.admin?)
  end
  def create_option?
    user_is_owner_of_question?
  end

  private

  def user_is_owner_of_question?
    iqtest = record.iqtest
    iqtest.user == user || user.admin?
  end
end
