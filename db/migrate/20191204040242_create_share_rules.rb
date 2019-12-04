class CreateShareRules < ActiveRecord::Migration[5.2]
  def change
    create_table :share_rules do |t|

      t.timestamps
    end
  end
end
