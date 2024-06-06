class UpdateUserTestScoresForPolymorphism < ActiveRecord::Migration[7.0]
  def change
    add_reference :user_test_scores, :question, null: false, foreign_key: true
    add_reference :user_test_scores, :option, null: false, foreign_key: true
    remove_reference :user_test_scores, :guest_user, index: true, foreign_key: true

    rename_column :user_test_scores, :userable_id, :user_id
    rename_column :user_test_scores, :userable_type, :user_type

    # Tentative de suppression d'un index qui pourrait exister
    remove_index :user_test_scores, name: "index_user_test_scores_on_userable_type_and_userable_id", if_exists: true
    remove_index :user_test_scores, name: "index_user_test_scores_on_user_type_and_user_id", if_exists: true

    # Ajout du nouvel index
    add_index :user_test_scores, [:user_type, :user_id], unique: true
  end
end
