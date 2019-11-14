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

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable#, :validatable

  validates_uniqueness_of :login, if: proc{|user| user.login.present?}
  validates_format_of :login, with: /\A1[3|4|5|8][0-9]\d{4,8}\z/, if: proc{|user| user.login.present?}
  before_save :ensure_authentication_token


  def ensure_authentication_token
    self.authentication_token ||= generate_authentication_token
  end

  def ensure_authentication_token!
    self.authentication_token = generate_authentication_token
    #记录登录时间TODO
    self.save
  end

  def email_required?
    false
  end

  #
  def send_code_sms
    self.update code: rand(100000..999999) , code_create_at: DateTime.now
    params = {
        region_id: 'default',
        code: Settings.aliyun_sms_code_template,
        phone: login,
        sign: Settings.aliyun_sign,
        params: {code: code}.to_json
    }
    SmsRecord.create params
  end

  class << self
    def send_code phone
      user = User.find_or_initialize_by phone
    end
  end



  private

  def generate_authentication_token
    loop do
      token = Devise.friendly_token
      break token unless User.where(authentication_token: token).first
    end
  end
end
