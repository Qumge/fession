class AddColumnCardToCash < ActiveRecord::Migration[5.2]
  def change
    add_column :cashes, :enc_true_name, :string
    add_column :cashes, :bank_code, :string
    add_column :cashes, :enc_bank_no, :string
  end
end
