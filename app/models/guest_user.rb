class GuestUser < ApplicationRecord
    has_many :user_test_scores, dependent: :destroy

  def convert_to_user(user_params)
    # Créer un nouvel utilisateur enregistré avec les paramètres fournis
    new_user = User.create(user_params)
    # Transférer les scores de l'utilisateur invité au nouvel utilisateur
    self.user_test_scores.update_all(user_id: new_user.id)
    # Détruire l'utilisateur invité
    self.destroy
    new_user # Retourner le nouvel utilisateur créé
  end
end
