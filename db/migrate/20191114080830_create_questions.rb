class CreateQuestions < ActiveRecord::Migration[5.2]
  def change
    create_table :questions do |t|
      t.string :type
      t.string :name
      t.integer :questionnaire_id
      t.timestamps
    end
  end
end
