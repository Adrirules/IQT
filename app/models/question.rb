class Question < ApplicationRecord
  belongs_to :iqtest

  validates :contentq, presence: true

end
