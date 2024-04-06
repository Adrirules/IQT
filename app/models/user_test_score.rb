class UserTestScore < ApplicationRecord
  belongs_to :user, polymorphic: true, optional: true # Permet aux utilisateurs non connectés (nil) d'être associés
  belongs_to :iqtest
  belongs_to :question
  belongs_to :option

  validates :iqtest, :question, :option, presence: true
end
