class CreateProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :products do |t|
      t.integer :company_id
      t.integer :category_id
      t.string :type
      t.string :name
      t.string :status
      t.integer :price
      t.string :no
      t.integer :stock, default: 0
      t.integer :sale, default: 0
      t.integer :coin
      t.text :desc
      t.timestamps
    end
  end
end
