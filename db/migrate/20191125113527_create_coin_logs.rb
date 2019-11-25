class CreateCoinLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :coin_logs do |t|
      t.string :channel
      t.integer :coin
      t.timestamps
    end
  end
end
