class CreateArticles < ActiveRecord::Migration[5.2]
  def change
    create_table :articles do |t|
      t.integer :company_id
      t.integer :product_id
      t.string :subject
      t.text :content
      t.timestamps
    end
  end
end
