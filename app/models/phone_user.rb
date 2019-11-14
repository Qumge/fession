# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  authentication_token   :string(255)
#  avatar_url             :string(255)
#  city                   :string(255)
#  code                   :string(255)
#  code_create_at         :datetime
#  coin                   :bigint
#  country                :string(255)
#  delete_at              :string(255)
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  gender                 :integer
#  login                  :string(255)
#  nick_name              :string(255)
#  province               :string(255)
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string(255)
#  session_key            :string(255)
#  session_token          :string(255)
#  unionid                :string(255)
#  view_num               :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  account_id             :integer
#  open_id                :string(255)
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#

class PhoneUser < User

  class << self

  end

  def get_code phone

  end

end
