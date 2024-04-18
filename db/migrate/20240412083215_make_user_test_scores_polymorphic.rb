class MakeUserTestScoresPolymorphic < ActiveRecord::Migration[7.0]
  def change
    remove_column :user_test_scores, :user_id
    add_column :user_test_scores, :userable_id, :bigint
    add_column :user_test_scores, :userable_type, :string
    add_index :user_test_scores, [:userable_type, :userable_id]


  end
end
