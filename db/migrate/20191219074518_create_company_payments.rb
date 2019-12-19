class CreateCompanyPayments < ActiveRecord::Migration[5.2]
  def change
    create_table :company_payments do |t|
      t.integer :company_id
      t.integer :amount
      t.string :status
      t.timestamps
    end
  end
end
