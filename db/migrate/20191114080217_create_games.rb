class CreateGames < ActiveRecord::Migration[5.2]
  def change
    create_table :games do |t|
      t.integer :company_id
      t.string :type
      t.string :name
      t.string :coin
      t.timestamps
    end
  end
end
