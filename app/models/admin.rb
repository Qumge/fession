# == Schema Information
#
# Table name: admins
#
#  id                     :bigint           not null, primary key
#  authentication_token   :string(255)
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  login                  :string(255)
#  name                   :string(255)
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string(255)
#  role_type              :string(255)
#  type                   :string(255)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  company_id             :integer
#  role_id                :integer
#
# Indexes
#
#  index_admins_on_reset_password_token  (reset_password_token) UNIQUE
#

class Admin < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable#, :validatable#, :confirmable
  #before_save :ensure_authentication_token
  validates_presence_of :login
  validates_uniqueness_of :login
  validates_format_of :login, with: /\A1[3-9][0-9]\d{4,8}\z/, if: proc{|admin| admin.login.present?}
  before_save :ensure_authentication_token
  after_create :set_password

  ROLE_TYPE = {admin: '超管', normal: '后端运营', admin_customer: '商户管理'}

  belongs_to :company
  belongs_to :role

  def ensure_authentication_token
    self.authentication_token ||= generate_authentication_token
  end

  def ensure_authentication_token!
    self.authentication_token = generate_authentication_token
    p generate_authentication_token, 111111
    #记录登录时间TODO
    self.save validate: false
    p self.errors
  end

  def email_required?
    false
  end

  def set_password
    unless self.role_type == 'super_admin'
      code = rand(100000..999999)
      self.update password: code
      params = {
          region_id: 'default',
          code: Settings.aliyun_sms_password_template,
          phone: login,
          sign: Settings.aliyun_sign,
          params: {code: code}.to_json
      }
      SmsRecord.create params
    end
  end

  private

  def generate_authentication_token
    loop do
      token = Devise.friendly_token
      break token unless Admin.where(authentication_token: token).first
    end
  end
end
