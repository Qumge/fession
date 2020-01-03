# == Schema Information
#
# Table name: cash_rules
#
#  id         :bigint           not null, primary key
#  coin       :integer          not null
#  floor      :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class CashRule < ApplicationRecord
end
