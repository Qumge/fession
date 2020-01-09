class AddColumnPayNoToCashes < ActiveRecord::Migration[5.2]
  def change
    add_column :cashes, :no, :string
  end
end
