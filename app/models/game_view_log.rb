# == Schema Information
#
# Table name: game_view_logs
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  game_id    :integer
#  user_id    :integer
#

class GameViewLog < ApplicationRecord
  belongs_to :game
  belongs_to :user
end
