class CreateOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :orders do |t|
      t.string :no
      t.integer :amount
      t.integer :company_id
      t.string :status
      t.integer :user_id
      t.string :type
      t.timestamps
    end
  end
end
