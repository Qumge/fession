class CreateNorms < ActiveRecord::Migration[5.2]
  def change
    create_table :norms do |t|
      t.integer :product_id
      t.integer :price
      t.string :name
      t.integer :stock
      t.integer :sale, default: 0
      t.timestamps
    end
  end
end
