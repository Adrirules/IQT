class MakeOrdersPolymorphic < ActiveRecord::Migration[7.0]
 def change
    remove_reference :orders, :user, index: true
    add_reference :orders, :responder, polymorphic: true, index: true
  end
end
