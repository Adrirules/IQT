class AddSessionIdToGuestUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :guest_users, :session_id, :string
    add_index :guest_users, :session_id, unique: true  # Assure une session unique par guest user
  end
end
