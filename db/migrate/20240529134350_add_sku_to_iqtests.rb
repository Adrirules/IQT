class AddSkuToIqtests < ActiveRecord::Migration[7.0]
  def change
    add_column :iqtests, :sku, :integer
  end
end
