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
    #判断今天第几次玩游戏
    w = user.game_logs.where('game_logs.created_at > ?', DateTime.now.beginning_of_day).size
    #概率加成
    pro = (6-w)/10.0 + 1
    self.game.prizes.order('probability desc').each_with_index do |prize, index|
      p index
      #基础概率
      normal = prize.probability * 10000
      #最终概率
      p normal
      if index == 0
        normal = normal * pro
      end
      p normal
      a += normal
      if s <= a
        p 333333
        PrizeLog.create user: self.user, game: self.game, prize: prize, game_log: self if prize.number.to_i > 0 || prize.type == 'Prize::CoinPrize'
        return
      end
    end
  end

end
