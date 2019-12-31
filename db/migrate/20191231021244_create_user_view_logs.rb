class CreateUserViewLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :user_view_logs do |t|
      t.integer :user_id
      t.integer :view_id
      t.timestamps
    end
  end
end
