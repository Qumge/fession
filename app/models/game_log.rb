# == Schema Information
#
# Table name: game_logs
#
#  id         :bigint           not null, primary key
#  coin       :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  game_id    :integer
#  user_id    :integer
#

class GameLog < ApplicationRecord
end
