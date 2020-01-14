class AddColumnCashedToOrders < ActiveRecord::Migration[5.2]
  def change
  	add_column :orders, :cashed, :boolean, default: 0
  	add_column :orders, :send_at, :datetime
  	add_column :orders, :receive_at, :datetime
  	add_column :companies, :cashes, :integer, default: 0
  end
end
