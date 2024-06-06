class AddStartTimeToIqtests < ActiveRecord::Migration[7.0]
  def change
    add_column :iqtests, :start_time, :datetime
  end
end
