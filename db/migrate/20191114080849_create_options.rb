class CreateOptions < ActiveRecord::Migration[5.2]
  def change
    create_table :options do |t|
      t.integer :question_id
      t.integer :name
      t.string :type
      t.timestamps
    end
  end
end
