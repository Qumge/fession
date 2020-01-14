class AddColumnBankToCompanies < ActiveRecord::Migration[5.2]
  def change
  	add_column :companies, :enc_bank_no, :string
  	add_column :companies, :enc_true_name, :string
  	add_column :companies, :bank_code, :string
  end
end
