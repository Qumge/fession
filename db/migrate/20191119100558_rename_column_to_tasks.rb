class RenameColumnToTasks < ActiveRecord::Migration[5.2]
  def change
    rename_column :tasks, :valid_form, :valid_from
  end
end
