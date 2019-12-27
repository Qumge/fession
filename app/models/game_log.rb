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
  belongs_to :user
  belongs_to :game
  after_create :win_prize
  has_one :prize_log


  def win_prize
    if game.cost.present?
      CoinLog.create company: game.company, model_id: self.id, user: user, channel: 'game', coin: game.cost - 2*game.cost
    end
    s = rand 1000000
    p s, 11111
    a = 0
    self.game.prizes.where('prizes.number > 0 or prizes.number = null').order('probability desc').each do |prize|
      p prize.probability * 10000, 2222
      a += prize.probability
      if s <= a * 10000
        p 333333
        PrizeLog.create user: self.user, game: self.game, prize: prize, game_log: self
        return
      end
    end
  end

end
