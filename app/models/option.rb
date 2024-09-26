class Option < ApplicationRecord
  belongs_to :question
  has_many :responses, dependent: :destroy # Ajoute cette ligne pour gérer la suppression des réponses associées

  has_one_attached :image

  validates :reponse, presence: true
  validates :isreponsecorrect, inclusion: { in: [true, false] }
end
