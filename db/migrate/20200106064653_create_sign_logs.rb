class CreateSignLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :sign_logs do |t|
      t.integer :user_id
      t.datetime :sign_at
      t.integer :days, default: 1
      t.timestamps
    end
  end
end
