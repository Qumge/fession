class AddColumnTokenToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :web_session_token, :string
    add_column :users, :web_openid, :string
    add_column :users, :ad_session_token, :string
    add_column :users, :ad_openid, :string
    add_column :users, :ios_session_token, :string
    add_column :users, :ios_openid, :string
    remove_column :users, :session_token
    remove_column :users, :session_key
  end
end
