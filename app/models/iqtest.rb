class Iqtest < ApplicationRecord

  validates :name, presence: true
  validates :description, presence: true
end
