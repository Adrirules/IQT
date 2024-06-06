class AddUniqueIdentifierToGuestUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :guest_users, :unique_identifier, :string
    add_index :guest_users, :unique_identifier, unique: true
  end
end
