class CreateBanners < ActiveRecord::Migration[5.2]
  def change
    create_table :banners do |t|
      t.string :type
      t.integer :task_id
      t.timestamps
    end
  end
end
