class RenameColumnToOptions < ActiveRecord::Migration[5.2]
  def change
    change_column :options, :name, :string
  end
end
