class AddColumnDescToGame < ActiveRecord::Migration[5.2]
  def change
    add_column :games, :desc, :text
  end
end
