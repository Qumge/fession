class AddColumnGetNumToTasks < ActiveRecord::Migration[5.2]
  def change
  	add_column :companies, :live, :boolean, default: true
  end
end
