class Option < ApplicationRecord
  belongs_to :question

  validates :reponse, presence: true
  validates :isreponsecorrect, inclusion: { in: [true, false] }
end
