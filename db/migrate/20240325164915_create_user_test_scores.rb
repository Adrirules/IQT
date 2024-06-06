class CreateUserTestScores < ActiveRecord::Migration[7.0]
  def change
    create_table :user_test_scores do |t|
      t.references :user, null: false, foreign_key: true
      t.references :iqtest, null: false, foreign_key: true
      t.integer :score

      t.timestamps
    end
  end
end
