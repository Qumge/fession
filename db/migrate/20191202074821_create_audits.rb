class CreateAudits < ActiveRecord::Migration[5.2]
  def change
    create_table :audits do |t|
      t.integer :model_id
      t.string :type
      t.string :form_status
      t.string :to_status
      t.integer :admin_id
      t.timestamps
    end
  end
end
