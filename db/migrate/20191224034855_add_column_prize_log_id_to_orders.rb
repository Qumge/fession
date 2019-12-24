class AddColumnPrizeLogIdToOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :prize_log_id, :integer
  end
end
