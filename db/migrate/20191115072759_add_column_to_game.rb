class AddColumnToGame < ActiveRecord::Migration[5.2]
  def change
    add_column :games, :cost, :integer
    add_column :games, :residue_coin, :bigint
  end
end
