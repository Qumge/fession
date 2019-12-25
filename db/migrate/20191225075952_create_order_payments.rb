class CreateOrderPayments < ActiveRecord::Migration[5.2]
  def change
    create_table :order_payments do |t|
      t.integer :payment_id
      t.integer :order_id
      t.timestamps
    end
  end
end
