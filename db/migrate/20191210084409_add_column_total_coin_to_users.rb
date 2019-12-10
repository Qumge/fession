class AddColumnTotalCoinToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :total_coin, :integer, default: 0
  end
end
