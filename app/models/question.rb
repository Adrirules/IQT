class Question < ApplicationRecord
  belongs_to :iqtest
  has_many :options, dependent: :destroy
  has_one_attached :imageq


  validates :contentq, presence: true
  accepts_nested_attributes_for :options, allow_destroy: true

  # Définit la méthode next_question pour récupérer la prochaine question dans la séquence
  def next_question
    # Recherchez toutes les questions pour le même IQTest, triées par ID,
    # et sélectionnez celle qui a un ID supérieur à l'ID de la question actuelle.
    self.iqtest.questions.where("id > ?", id).order(id: :asc).first
  end

end
