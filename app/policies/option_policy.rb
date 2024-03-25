class OptionPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  def new
    create?
  end

  def create?
    user.admin? # Seuls les administrateurs peuvent créer des options
  end

  def show?
    true # Autoriser tout le monde à voir les options
  end

  def update?
    user&.admin? # Seuls les administrateurs peuvent mettre à jour des options
  end

  def destroy?
    user&.admin? # Seuls les administrateurs peuvent supprimer des options
  end
end
