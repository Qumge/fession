class AddColumnToAfterOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :after_orders, :type, :string
  end
end
