class AddEmailToGuestUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :guest_users, :email, :string
  end
end
