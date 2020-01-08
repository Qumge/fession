class AddColumnTransactionIdToPayment < ActiveRecord::Migration[5.2]
  def change
    add_column :payments, :transaction_id, :string
    add_column :payments, :refund_response, :string
  end
end
