class CreateSignRules < ActiveRecord::Migration[5.2]
  def change
    create_table :sign_rules do |t|

      t.timestamps
    end
  end
end
