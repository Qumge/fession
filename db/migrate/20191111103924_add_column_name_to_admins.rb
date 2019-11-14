class AddColumnNameToAdmins < ActiveRecord::Migration[5.2]
  def change
    add_column :admins, :name, :string
    add_column :admins, :role_id, :integer
    add_column :admins, :role_type, :string
  end
end
