class RemoveColumnToOptions < ActiveRecord::Migration[5.2]
  def change
    remove_column :options, :type
  end
end
