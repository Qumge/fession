class AddColumnToAudits < ActiveRecord::Migration[5.2]
  def change
    add_column :audits, :reason, :text
  end
end
