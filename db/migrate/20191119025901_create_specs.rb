class CreateSpecs < ActiveRecord::Migration[5.2]
  def change
    create_table :specs do |t|
      t.integer :product_id
      t.string :name
      t.timestamps
    end
  end
end
