class AddColumnCardToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :card_no, :string
    add_column :users, :real_name, :string
  end
end
