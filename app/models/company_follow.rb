# == Schema Information
#
# Table name: company_follows
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  follow_id  :integer
#  user_id    :integer
#

class CompanyFollow < ApplicationRecord
end
