class AddColumnToBanners < ActiveRecord::Migration[5.2]
  def change
    add_column :banners, :company_id, :integer
  end
end
