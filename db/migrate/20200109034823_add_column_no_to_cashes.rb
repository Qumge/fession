class AddColumnNoToCashes < ActiveRecord::Migration[5.2]
  def change
    add_column :cashes, :pay_status, :string
  end
end
