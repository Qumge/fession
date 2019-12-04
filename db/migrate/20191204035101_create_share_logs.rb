class CreateShareLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :share_logs do |t|
      t.integer :user_id
      t.integer :fission_log_id
      t.timestamps
    end
  end
end
