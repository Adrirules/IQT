class AddGuestUserIdToUserTestScores < ActiveRecord::Migration[7.0]
  def change
    add_reference :user_test_scores, :guest_user, null: false, foreign_key: true
  end
end
