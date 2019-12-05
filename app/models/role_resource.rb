# == Schema Information
#
# Table name: role_resources
#
#  id          :bigint           not null, primary key
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  resource_id :integer
#  role_id     :integer
#

class RoleResource < ApplicationRecord
end
