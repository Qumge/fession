class CreateCompanyFollows < ActiveRecord::Migration[5.2]
  def change
    create_table :company_follows do |t|
      t.integer :follow_id
      t.integer :user_id
      t.timestamps
    end
  end
end
