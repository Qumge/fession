class CreateCompanyCashes < ActiveRecord::Migration[5.2]
  def change
    create_table :company_cashes do |t|
      t.integer :company_id
      t.string :status
      t.string :response_data
      t.string :enc_bank_no
      t.string :enc_true_name
      t.string :bank_code
      t.string :no
      t.integer :amount
      t.timestamps
    end
  end
end
