class AddColumnToRules < ActiveRecord::Migration[5.2]
  def change
    add_column :share_rules, :level, :integer
    add_column :share_rules, :coin, :integer

    add_column :sign_rules, :number, :integer
    add_column :sign_rules, :coin, :integer
  end
end
