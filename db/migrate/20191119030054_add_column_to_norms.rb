class AddColumnToNorms < ActiveRecord::Migration[5.2]
  def change
    add_column :norms, :spec_attrs, :string
  end
end
