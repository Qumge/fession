class CreatePayments < ActiveRecord::Migration[5.2]
  def change
    create_table :payments do |t|
      t.integer :order_id
      t.integer :user_id
      t.string :type
      t.string :status
      t.integer :amount
      t.timestamps
    end
  end
end
