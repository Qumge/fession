# == Schema Information
#
# Table name: admins
#
#  id                     :bigint           not null, primary key
#  authentication_token   :string(255)      default("")
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  login                  :string(255)
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string(255)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_admins_on_email                 (email) UNIQUE
#  index_admins_on_reset_password_token  (reset_password_token) UNIQUE
#

class Admin < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable#, :confirmable
  #before_save :ensure_authentication_token
  validates :password_confirmation, presence: true, on: :create
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

  private

  def generate_authentication_token
    loop do
      token = Devise.friendly_token
      break token unless Admin.where(authentication_token: token).first
    end
  end
end
