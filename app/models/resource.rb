# == Schema Information
#
# Table name: resources
#
#  id         :bigint           not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  role_id    :integer
#

class Resource < ApplicationRecord
  belongs_to :role
  validates_presence_of :name
  validates_uniqueness_of :name
end
