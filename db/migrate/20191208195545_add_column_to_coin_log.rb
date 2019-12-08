class AddColumnToCoinLog < ActiveRecord::Migration[5.2]
  def change
    add_column :coin_logs, :share_log_id, :integer
  end
end
