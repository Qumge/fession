class AddColumnExpressToOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :express_no, :string
    add_column :orders, :express_type, :string
  end
end
