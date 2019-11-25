class AddColumnToAdmins < ActiveRecord::Migration[5.2]
  def change
    add_column :admins, :status, :string, default: :active
  end
end
