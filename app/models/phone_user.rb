# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  ad_openid              :string(255)
#  ad_session_token       :string(255)
#  app_openid             :string(255)
#  app_session_token      :string(255)
#  authentication_token   :string(255)
#  avatar_url             :string(255)
#  card_no                :string(255)
#  city                   :string(255)
#  code                   :string(255)
#  code_create_at         :datetime
#  coin                   :bigint
#  country                :string(255)
#  delete_at              :string(255)
#  deleted_at             :datetime
#  desc                   :string(255)
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  gender                 :integer
#  ios_openid             :string(255)
#  ios_session_token      :string(255)
#  last_active_at         :datetime
#  login                  :string(255)
#  nick_name              :string(255)
#  province               :string(255)
#  real_name              :string(255)
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string(255)
#  total_coin             :integer          default(0)
#  unionid                :string(255)
#  view_num               :integer
#  web_openid             :string(255)
#  web_session_token      :string(255)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  account_id             :integer
#  open_id                :string(255)
#
# Indexes
#
#  index_users_on_deleted_at  (deleted_at)
#

class PhoneUser < User

  class << self

  end

  def get_code phone

  end

end
