class Question < ApplicationRecord
  belongs_to :iqtest
  has_many :options, dependent: :destroy

  validates :contentq, presence: true
  accepts_nested_attributes_for :options, allow_destroy: true

end
