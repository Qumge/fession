class AddColumnToCashes < ActiveRecord::Migration[5.2]
  def change
    add_column :cashes, :response_data, :text
  end
end
