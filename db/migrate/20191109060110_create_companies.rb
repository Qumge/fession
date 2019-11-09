class CreateCompanies < ActiveRecord::Migration[5.2]
  def change
    create_table :companies do |t|
      t.string :name
      t.string :no
      t.string :status
      t.datetime :active_at
      t.datetime :locked_at
      t.bigint  :coin, default: 0
      t.bigint :total_amount, default: 0
      t.bigint :active_amount, default: 0
      t.bigint :withdraw_amount, default: 0
      t.bigint :invalid_amount, default: 0
      t.bigint :return_amount, default: 0
      t.timestamps
    end
  end
end
