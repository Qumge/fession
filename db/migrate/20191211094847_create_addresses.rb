class CreateAddresses < ActiveRecord::Migration[5.2]
  def change
    create_table :addresses do |t|
      t.string :name
      t.string :phone
      t.string :content
      t.string :tag
      t.integer :user_id
      t.integer :company_id
      t.timestamps
    end
  end
end
