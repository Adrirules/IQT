class AddUserToIqtests < ActiveRecord::Migration[7.0]
  def change
    add_reference :iqtests, :user, null: false, foreign_key: true
  end
end
