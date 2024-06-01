class AddPriceToIqtests < ActiveRecord::Migration[7.0]
  def change
    add_monetize :iqtests, :price, currency: { present: false }
  end
end
