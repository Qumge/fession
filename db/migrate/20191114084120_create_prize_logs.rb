class CreatePrizeLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :prize_logs do |t|
      t.integer :game_id
      t.integer :prize_id
      t.integer :order_id
      t.integer :user_id
      t.timestamps
    end
  end
end
