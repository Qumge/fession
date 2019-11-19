class CreatePrizes < ActiveRecord::Migration[5.2]
  def change
    create_table :prizes do |t|
      t.integer :game_id
      t.string :type
      t.integer :coin
      t.string :content
      t.integer :number
      t.timestamps
    end
  end
end
