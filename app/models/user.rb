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
#  deleted_at             :datetime
#  desc                   :string(255)
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
#  index_users_on_deleted_at            (deleted_at)
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable#, :validatable

  validates_uniqueness_of :login, if: proc{|user| user.login.present?}
  validates_format_of :login, with: /\A1[3|4|5|7|8][0-9]{9}\z/, if: proc{|user| user.login.present?}
  before_save :ensure_authentication_token
  has_and_belongs_to_many :follow_companies, join_table: 'company_follows',  association_foreign_key: :follow_id, class_name: 'Company'
  has_and_belongs_to_many :follow_users, join_table: 'user_follows',  association_foreign_key: :follow_id, class_name: "User"

  has_and_belongs_to_many :followers , join_table: 'user_follows', foreign_key: :follow_id, class_name: "User"
  has_many :coin_logs
  has_many :fission_logs
  has_many :share_logs
  has_many :posts
  has_many :addresses
  has_many :cashes
  has_many :orders



  class << self
    def search_conn params
      users = self.all
      if params[:search].present?
        users = users.where('nick_name like ? or login like ?', "%#{params[:search]}%", "%#{params[:search]}%")
      end
      users
    end

    def init_by_web_code code, type
      res = Wechat.api(type).web_access_token code
      if res && res['openid']
        init_by_web_session res['access_token'], res['openid'], type
      end
    end

    def init_by_web_session access_token, openid, type
      user_info = Wechat.api(type).web_userinfo access_token, openid
      p user_info
      if user_info['unionid']
        user = User.find_or_initialize_by unionid: user_info['unionid']
        if type.to_s == 'default'
          user.web_session_token = access_token
          user.web_openid = user_info['openid']
        end

        if type.to_s == 'app'
          user.app_session_token = access_token
          user.app_openid = user_info['openid']
        end

        user.nick_name = user_info['nickname']
        user.gender = user_info['sex']
        user.city = user_info['city']
        user.province = user_info['province']
        user.country = user_info['country']
        user.avatar_url = user_info['headimgurl']
        user.save
        user
      end
    end
  end



  def ensure_authentication_token
    self.authentication_token ||= generate_authentication_token
  end

  def ensure_authentication_token!
    self.authentication_token ||= generate_authentication_token
    #记录登录时间TODO
    self.save
  end


  def email_required?
    false
  end

  def fission_log task
    fission_logs.find_by(user: task)
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

  def fetch_params params
    self.nick_name = params[:nick_name] if params[:nick_name].present?
    self.desc = params[:desc] if params[:desc].present?
    self.avatar_url = params[:avatar_url] if params[:avatar_url].present?
    self.login = params[:login] if params[:login].present?
  end

  # class << self
  #   def send_code phone
  #     user = User.find_or_initialize_by phone
  #   end
  # end



  private

  def generate_authentication_token
    loop do
      token = Devise.friendly_token
      break token unless User.where(authentication_token: token).first
    end
  end
end
