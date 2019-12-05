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
end
