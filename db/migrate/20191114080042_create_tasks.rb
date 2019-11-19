class CreateTasks < ActiveRecord::Migration[5.2]
  def change
    create_table :tasks do |t|
      t.string :type
      t.integer :model_id
      t.integer :company_id
      t.bigint :coin
      t.bigint :residue_coin
      t.datetime :valid_form
      t.datetime :valid_to
      t.string :status
      t.string :name
      t.timestamps
    end
  end
end
