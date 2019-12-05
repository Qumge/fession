# == Schema Information
#
# Table name: resources
#
#  id         :bigint           not null, primary key
#  deleted_at :datetime
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  role_id    :integer
#
# Indexes
#
#  index_resources_on_deleted_at  (deleted_at)
#

class Resource < ApplicationRecord
  belongs_to :role
  validates_presence_of :name
  validates_uniqueness_of :name
end
