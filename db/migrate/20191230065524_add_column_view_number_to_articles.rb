class AddColumnViewNumberToArticles < ActiveRecord::Migration[5.2]
  def change
    add_column :articles, :view_num, :integer, default: 0
    add_column :articles, :product_view_num, :integer, default: 0
  end
end
