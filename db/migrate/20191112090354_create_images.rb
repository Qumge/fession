class CreateImages < ActiveRecord::Migration[5.2]
  def change
    create_table :images do |t|
      t.integer :model_id
      t.string :model_type
      t.string :file_path
      t.timestamps
    end
  end
end
