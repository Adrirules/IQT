class Iqtest < ApplicationRecord

  validates :name, presence: true
  validates :description, presence: true

  has_many  :questions, dependent: :destroy
  belongs_to :user
  has_many :user_test_scores, dependent: :destroy


end