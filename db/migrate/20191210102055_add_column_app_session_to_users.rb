class AddColumnAppSessionToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :app_session_token, :string
    add_column :users, :app_openid, :string
  end
end
