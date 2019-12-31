class CreateAfterOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :after_orders do |t|
      t.integer :user_id
      t.integer :order_id
      t.string :status
      t.string :express_no
      t.string :express_type
      t.timestamps
    end
  end
end
