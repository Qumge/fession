class CreateQuestionnaires < ActiveRecord::Migration[5.2]
  def change
    create_table :questionnaires do |t|
      t.integer :company_id
      t.string :desc
      t.string :name
      t.timestamps
    end
  end
end
