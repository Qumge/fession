class CreateOrderProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :order_products do |t|
      t.integer :norm_id
      t.integer :product_id
      t.integer :order_id
      t.integer :number
      t.integer :price
      t.integer :amount
      t.timestamps
    end
  end
end
