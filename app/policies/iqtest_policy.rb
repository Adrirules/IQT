class IqtestPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  def index?
    user.admin? # Seuls les administrateurs peuvent créer de nouveaux IQTests
  end
  def show?
    user.admin? # Seuls les administrateurs peuvent créer de nouveaux IQTests
  end

  def create?
    user.admin? # Seuls les administrateurs peuvent créer de nouveaux IQTests
  end

  def update?
    user.admin? # Seuls les administrateurs peuvent mettre à jour les IQTests
  end

  def destroy?
    user.admin? # Seuls les administrateurs peuvent supprimer les IQTests
  end

  def show_score?
    true
  end
end
