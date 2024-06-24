class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  # ... configurations de Devise ...
  has_many :iqtests, dependent: :destroy
  has_many :user_test_scores, dependent: :destroy
  has_many :responses, as: :responder, dependent: :destroy
  has_many :orders, as: :responder, dependent: :destroy
  has_many :user_test_scores, as: :responder

  attribute :user_type, :string
  # Callback to reassociate orders if email changes
  before_update :reassociate_orders, if: :will_save_change_to_email?

  private

  def reassociate_orders
    # Ensure that the orders model has an 'email' attribute or this will need to be adjusted.
    # Adjust this logic based on how orders are actually associated to users.
    # For example, you might need to update 'user_id' instead if orders are linked by user ID.
    # Example: Order.where(user_id: id_was).update_all(user_id: id)
    orders.update_all(email: email)
  end
end
