class AddColumnCompanyIdToCoinLog < ActiveRecord::Migration[5.2]
  def change
    add_column :coin_logs, :company_id, :integer
    add_column :coin_logs, :model_id, :integer
  end
end
