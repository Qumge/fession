class CreateLogistics < ActiveRecord::Migration[5.2]
  def change
    create_table :logistics do |t|
      t.string :no
      t.integer :return_order_id
      t.string :name
      t.integer :order_id
      t.timestamps
    end
  end
end
