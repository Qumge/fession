class AddColumnToCoinLogs < ActiveRecord::Migration[5.2]
  def change
    add_column :coin_logs, :user_id, :integer
  end
end
