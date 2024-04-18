class MakeResponsesPolymorphic < ActiveRecord::Migration[7.0]
  def change
    remove_reference :responses, :user, index: true, foreign_key: true
    add_reference :responses, :responder, polymorphic: true, null: false, index: true
  end
end
