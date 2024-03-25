class IqtestPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  def show?
    true # Autoriser tout le monde à voir les IQTests
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
end
