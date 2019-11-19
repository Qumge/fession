class CreateSpecValues < ActiveRecord::Migration[5.2]
  def change
    create_table :spec_values do |t|
      t.integer :spec_id
      t.string :name
      t.timestamps
    end
  end
end
