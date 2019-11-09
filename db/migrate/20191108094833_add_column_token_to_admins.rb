class AddColumnTokenToAdmins < ActiveRecord::Migration[5.2]
  def change
    add_column :admins, :authentication_token, :string
    add_column :admins, :type, :string
    add_column :admins, :company_id, :integer
  end
end
