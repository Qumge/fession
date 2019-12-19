# == Schema Information
#
# Table name: games
#
#  id           :bigint           not null, primary key
#  coin         :string(255)
#  cost         :integer
#  deleted_at   :datetime
#  desc         :text(65535)
#  name         :string(255)
#  residue_coin :bigint
#  type         :string(255)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  company_id   :integer
#
# Indexes
#
#  index_games_on_deleted_at  (deleted_at)
#

class Game < ApplicationRecord
  validates_presence_of :cost, if: proc{|game| game.company.blank?}
  validates_presence_of :coin, if: proc{|game| game.company.present?}
 # validates_presence_of :company_id, if: proc{|game| game.cost.present?}
  has_many :prizes
  has_many :prize_logs
  belongs_to :company
  has_one :image, -> {where(model_type: 'Game')}, foreign_key: :model_id
  has_one :task_game_task, :class_name => 'Task::GameTask', foreign_key: :model_id


  def fetch_prizes params_prizes
    #params_prizes = [{product_id: 1, probability: 0.01, number: 1}, { coin: 200, probability: 0.01, number: 2}]
    prizes = []
    p params_prizes, 1111
    params_prizes.each do |params_prize|
      if params_prize['product_id'].present?
        p params_prize['product_id'], 11111
        prize = self.prizes.find_or_initialize_by product_id: params_prize['product_id'], type: 'Prize::ProductPrize'
      else
        prize = self.prizes.find_or_initialize_by coin: params_prize['coin'], type: 'Prize::CoinPrize'
      end
      prize.probability = params_prize['probability']
      prize.number = params_prize['number']
      p prize.valid? ,1222222
      prizes << prize
    end
    self.prizes = prizes
    self.save
    self
  end

  def play user
    if self.can_play? user
      GameLog.create user: user, game: self, coin: self.cost
    else
      raise '金币不足或者次数已用完'
    end
  end

  def can_play? user
    if time_valid?
      if self.cost.present?
        user.coin > self.cost
      else
        GameLog.find_by(game: self, user: user).blank?
      end
    else
      false
    end

  end

  def time_valid?
    (self.cost.present? && self.company.blank?) || (self.cost.blank? && self.task_game_task.success? && self.task_game_task.time_valid?)
  end

  def cost_coin
    self.coin.to_i - self.residue_coin.to_i
  end

  #中奖人数
  def prize_user_num
    self.prize_logs.size
  end

  #中奖金币数
  def prize_coin
    self.coin.to_i - self.residue_coin.to_i
  end

  #中奖商品数
  def prize_product_num
    self.prize_logs.joins(:prize).where('prizes.type = ?', 'Prize::ProductPrize').size
  end

end
