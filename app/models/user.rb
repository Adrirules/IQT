class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  # ... configurations de Devise ...
    has_many :iqtests, dependent: :destroy
    has_many :user_test_scores, dependent: :destroy

  attribute :user_type, :string

end
