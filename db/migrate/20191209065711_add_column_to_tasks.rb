class AddColumnToTasks < ActiveRecord::Migration[5.2]
  def change
    add_column :tasks, :share_num, :integer, default: 0
  end
end
