class AddColumnCoinToCompanyPayments < ActiveRecord::Migration[5.2]
  def change
  	add_column :company_payments, :coin, :integer
  end
end
