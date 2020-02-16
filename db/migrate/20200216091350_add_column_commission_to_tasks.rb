class AddColumnCommissionToTasks < ActiveRecord::Migration[5.2]
  def change
  	add_column :tasks, :commission, :integer
  end
end
