class AddColumnToAnswer < ActiveRecord::Migration[5.2]
  def change
    add_column :answers, :reply_id, :integer
  end
end
