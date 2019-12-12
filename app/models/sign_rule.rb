# == Schema Information
#
# Table name: sign_rules
#
#  id         :bigint           not null, primary key
#  coin       :integer
#  number     :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class SignRule < ApplicationRecord
  validates_presence_of :coin
  validates_presence_of :number
  validates_uniqueness_of :number

  class << self
    def fetch_params params
      sign_rules = []
      rules = JSON.parse params[:rules]
      rules.each do |rule|
        sign_rule = SignRule.find_or_initialize_by number: rule['number']
        sign_rule.update coin: rule['coin']
        sign_rules << sign_rule
      end
      sign_rules
    end
  end

end
