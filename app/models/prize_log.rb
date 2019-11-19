# == Schema Information
#
# Table name: prize_logs
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  game_id    :integer
#  order_id   :integer
#  prize_id   :integer
#  user_id    :integer
#

class PrizeLog < ApplicationRecord
end
