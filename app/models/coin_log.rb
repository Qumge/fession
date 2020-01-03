# == Schema Information
#
# Table name: coin_logs
#
#  id           :bigint           not null, primary key
#  channel      :string(255)
#  coin         :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  company_id   :integer
#  model_id     :integer
#  share_log_id :integer
#  user_id      :integer
#

class CoinLog < ApplicationRecord
  belongs_to :user
  belongs_to :company
  CHANNEL = {fission: '转发裂变', sign: '签到', game: '游戏抽奖', cash: '提现', prize: '中奖', failed_cash: '提现拒绝返还', product: '购买返金币', order: '金币商城消费'}
  belongs_to :fission_log, foreign_key: :model_id
  belongs_to :share_log
  belongs_to :prize_log, foreign_key: :model_id
  belongs_to :game_log, foreign_key: :model_id
  belongs_to :order_product, foreign_key: :model_id
  belongs_to :order, foreign_key: :model_id
  #belongs_to :sign_log, foreign_key: :model_id

  after_create :set_coin

  class << self
    def search_conn params
      logs = self.all
      if params[:type].present?
        channels = []
        case params[:type]
        when 'in'
          channels = ['sign', 'fission', 'prize', 'failed_cash', 'product']
        when 'out'
          channels = ['game', 'order', 'cash']
        end
        logs = logs.where(channel: channels)
      end
      logs
    end
  end

  def get_channel
    CHANNEL[self.channel.to_sym]
  end

  def user_name
    self.user&.nick_name
  end

  def share_name
    self.share_log&.user&.nick_name
  end

  def set_coin
    case self.channel
    when 'fission'
      user.update coin: user.coin.to_i + coin
      fission_log.task.update residue_coin: fission_log.task.residue_coin.to_i - coin
      company.update coin: company.coin.to_i - coin
    when 'sign'
      user.update coin: user.coin.to_i + coin
    when 'game'
      user.update coin: user.coin.to_i + coin
    when 'cash'
      user.update coin: user.coin.to_i + coin
    when 'failed_cash'
      user.update coin: user.coin.to_i + coin
    when 'prize'
      user.update coin: user.coin + coin
      prize_log.game.update residue_coin: prize_log.game.residue_coin.to_i - coin if prize_log.game.present?
      company.update coin: company.coin.to_i - coin if company.present?
    when 'order'
      user.update coin: user.coin.to_i + coin
    end
  end

end
