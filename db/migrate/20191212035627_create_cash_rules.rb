class CreateCashRules < ActiveRecord::Migration[5.2]
  def change
    create_table :cash_rules do |t|
      t.integer :coin, null: false
      t.integer :floor, null: false
      t.timestamps
    end
  end
end
