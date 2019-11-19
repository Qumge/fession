class CreateGameLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :game_logs do |t|
      t.integer :game_id
      t.integer :coin
      t.integer :user_id
      t.timestamps
    end
  end
end
