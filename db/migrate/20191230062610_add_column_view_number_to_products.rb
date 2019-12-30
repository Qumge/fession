class AddColumnViewNumberToProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :view_num, :integer, default: 0
    add_column :products, :amount, :integer, default: 0
    add_column :products, :sale_coin, :integer, default: 0
    add_column :tasks, :sale, :integer, default: 0
    add_column :tasks, :amount, :integer, default: 0
    add_column :tasks, :sale_coin, :integer,  default: 0
  end
end
