class AddColumnToPrize < ActiveRecord::Migration[5.2]
  def change
    add_column :prizes, :product_id, :integer
    add_column :prizes, :probability, :float
  end
end
