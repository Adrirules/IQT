class QuestionPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  def show?
    true # Autoriser tout le monde à voir les questions
  end

  def create?
    user&.admin? # Seuls les administrateurs peuvent créer des questions
  end

  def update?
    user&.admin? # Seuls les administrateurs peuvent mettre à jour des questions
  end

  def destroy?
    user&.admin? # Seuls les administrateurs peuvent supprimer des questions
  end

  def create_option?
    user&.admin? # Seuls les administrateurs peuvent créer des options pour les questions
  end

  def first_question?
    true
  end

  def next_question?
    true
  end

  def collect_responses?
    true
  end

  def select_option?
    true
  end

  def start_test?
    true
  end
end
