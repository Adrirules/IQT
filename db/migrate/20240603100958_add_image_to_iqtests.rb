class AddImageToIqtests < ActiveRecord::Migration[7.0]
  def change
    add_column :iqtests, :image, :string
  end
end
