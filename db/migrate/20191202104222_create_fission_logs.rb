class CreateFissionLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :fission_logs do |t|
      t.integer :task_id
      t.integer :user_id
      t.string :token
      t.string :ancestry
      t.timestamps
    end
  end
end
