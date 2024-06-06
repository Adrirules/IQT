class AddImageqToQuestions < ActiveRecord::Migration[7.0]
  def change
    add_column :questions, :imageq, :string
  end
end
