class AddResponderToUserTestScores < ActiveRecord::Migration[7.0]
  def change
    add_column :user_test_scores, :responder_type, :string
    add_column :user_test_scores, :responder_id, :integer
    add_index :user_test_scores, [:responder_type, :responder_id]

  end
end
