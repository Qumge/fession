class AddColumnViewNumberToTasks < ActiveRecord::Migration[5.2]
  def change
    add_column :tasks, :view_num, :integer, default: 0
  end
end
