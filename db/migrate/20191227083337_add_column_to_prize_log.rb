class AddColumnToPrizeLog < ActiveRecord::Migration[5.2]
  def change
    add_column :prize_logs, :game_log_id, :integer
  end
end
