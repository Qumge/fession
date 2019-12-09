class AddColumnToBanner < ActiveRecord::Migration[5.2]
  def change
    add_column :banners, :no, :integer
  end
end
