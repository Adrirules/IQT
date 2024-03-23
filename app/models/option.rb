class Option < ApplicationRecord
  belongs_to :question
  has_one_attached :image


  validates :reponse, presence: true
  validates :isreponsecorrect, inclusion: { in: [true, false] }
end
