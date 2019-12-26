class AddColumnPlatformToOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :platform, :string
  end
end
