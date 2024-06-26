class UserTestScore < ApplicationRecord
  belongs_to :user, polymorphic: true, optional: true
  belongs_to :iqtest
  belongs_to :question
  belongs_to :option
  belongs_to :responder, polymorphic: true

  validates :iqtest, :question, :option, presence: true
end
