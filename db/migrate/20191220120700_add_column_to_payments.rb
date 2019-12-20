class AddColumnToPayments < ActiveRecord::Migration[5.2]
  def change
    add_column :company_payments, :no, :string
    add_column :company_payments, :apply_res, :text
    add_column :company_payments, :prepay_id, :string
    add_column :company_payments, :qrcode, :string

  end
end
