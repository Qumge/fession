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

  def self.fetch_params params
    params.each do |rule_hash|
      rule = ShareRule.find_or_initialize_by level: rule_hash['level'].to_i
      rule.update coin: rule_hash['coin'].to_i
    end
    ShareRule.all.order('level')
  end
end
