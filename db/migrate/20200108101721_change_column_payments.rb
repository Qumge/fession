class ChangeColumnPayments < ActiveRecord::Migration[5.2]
  def change
    change_column :payments, :refund_response, :text
  end
end
