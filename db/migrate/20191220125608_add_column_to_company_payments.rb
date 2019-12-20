class AddColumnToCompanyPayments < ActiveRecord::Migration[5.2]
  def change
    add_column :company_payments, :response_data, :text
  end
end
