class UserTestScore < ApplicationRecord
  belongs_to :user
  belongs_to :iqtest
end
