# == Schema Information
#
# Table name: prize_logs
#
#  id          :bigint           not null, primary key
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  game_id     :integer
#  game_log_id :integer
#  order_id    :integer
#  prize_id    :integer
#  user_id     :integer
#

class PrizeLog < ApplicationRecord
  after_create :award_prize
  belongs_to :prize
  belongs_to :game
  has_one :order
  belongs_to :user
  belongs_to :game_log

  def award_prize
    case prize.type
    when 'Prize::CoinPrize'
      CoinLog.create company: game.company, model_id: self.id, user: user, channel: 'prize', coin: prize.coin
      if game.residue_coin.present? && prize.coin.present?
        game.update residue_coin: game.residue_coin - prize.coin
        game.company.update coin: game.company.coin - prize.coin if game.company.present?
      end
    when 'Prize::ProductPrize'
      # 生成一个订单
      Order.prize_order user, prize.product, self
    end
    prize.update number: prize.number - 1
  end

end
