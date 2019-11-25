class CreateRoleResources < ActiveRecord::Migration[5.2]
  def change
    create_table :role_resources do |t|
      t.integer :role_id
      t.integer :resource_id
      t.timestamps
    end
  end
end
