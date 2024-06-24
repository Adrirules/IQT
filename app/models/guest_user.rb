class GuestUser < ApplicationRecord
  has_many :user_test_scores, dependent: :destroy
  has_many :responses, as: :responder, dependent: :destroy
  has_many :orders, as: :responder, dependent: :destroy
  has_many :user_test_scores, as: :responder

  validates :email, presence: true, uniqueness: true
  validates :session_id, presence: true


  def self.find_or_create_by_session(session_id)
    find_or_create_by(session_id: session_id)
  end

  def convert_to_user(user_params)
    ApplicationRecord.transaction do
      new_user = User.create!(user_params)
      self.user_test_scores.update_all(user_id: new_user.id)
      self.responses.update_all(responder: new_user)
      self.orders.update_all(responder: new_user)
      self.destroy
      new_user
    end
  rescue ActiveRecord::RecordInvalid => e
    puts "Erreur de conversion: #{e.message}"
    nil
  end
end
