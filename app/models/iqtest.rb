class Iqtest < ApplicationRecord

  validates :name, presence: true
  validates :description, presence: true

  has_many  :questions, dependent: :destroy
  belongs_to :user

end
