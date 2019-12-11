class AddColumnNumberToTasks < ActiveRecord::Migration[5.2]
  def change
    add_column :tasks, :number, :integer, default: 0
  end
end
