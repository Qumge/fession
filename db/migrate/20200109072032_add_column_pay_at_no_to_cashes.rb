class AddColumnPayAtNoToCashes < ActiveRecord::Migration[5.2]
  def change
    add_column :cashes, :pay_at, :datetime
  end
end
