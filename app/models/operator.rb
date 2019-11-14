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

class Operator < Admin
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  belongs_to :role
  validates_presence_of :role_id, if: proc{|operator| operator.role_type == 'normal'}
  validates_presence_of :role_type
  ROLE_TYPE = {'admin': '超管', 'normal': '运营'}
end
