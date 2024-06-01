class CreateOrders < ActiveRecord::Migration[7.0]
  def change
    create_table :orders do |t|
      t.string :state
      t.string :iqtest_sku
      t.integer :amount_cents
      t.string :checkout_session_id

      t.timestamps
    end
  end
end
