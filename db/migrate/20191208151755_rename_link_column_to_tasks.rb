class RenameLinkColumnToTasks < ActiveRecord::Migration[5.2]
  def change
    rename_column :tasks, :link, :share_link
  end
end
