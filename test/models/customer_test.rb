# == Schema Information
#
# Table name: admins
#
#  id                     :bigint           not null, primary key
#  authentication_token   :string(255)
#  deleted_at             :datetime
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  login                  :string(255)
#  name                   :string(255)
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string(255)
#  role_type              :string(255)
#  status                 :string(255)      default("active")
#  type                   :string(255)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  company_id             :integer
#  role_id                :integer
#
# Indexes
#
#  index_admins_on_deleted_at            (deleted_at)
#  index_admins_on_reset_password_token  (reset_password_token) UNIQUE
#

require 'test_helper'

class CustomerTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
