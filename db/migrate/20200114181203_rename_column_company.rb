class RenameColumnCompany < ActiveRecord::Migration[5.2]
  def change
  	change_column :company_cashes, :response_data, :text
  end
end
