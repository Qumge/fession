class CreateResources < ActiveRecord::Migration[5.2]
  def change
    create_table :resources do |t|
      t.integer :role_id
      t.string :name
      t.timestamps
    end
  end
end
