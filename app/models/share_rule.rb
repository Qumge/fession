# == Schema Information
#
# Table name: share_rules
#
#  id         :bigint           not null, primary key
#  coin       :integer
#  level      :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ShareRule < ApplicationRecord
  validates_presence_of :coin
  validates_presence_of :level
end
