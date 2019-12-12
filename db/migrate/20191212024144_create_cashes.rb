class CreateCashes < ActiveRecord::Migration[5.2]
  def change
    create_table :cashes do |t|
      t.integer :user_id
      t.integer :coin
      t.integer :amount
      t.string :status
      t.timestamps
    end
  end
end
