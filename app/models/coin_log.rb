# == Schema Information
#
# Table name: coin_logs
#
#  id         :bigint           not null, primary key
#  channel    :string(255)
#  coin       :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :integer
#

class CoinLog < ApplicationRecord
  belongs_to :user
  belongs_to :company
  CHANNEL = {fission: '转发裂变', sign: '签到', game: '游戏抽奖', cash: '提现', prize: '中奖'}
  belongs_to :fission_log, foreign_key: :model_id
  #belongs_to :sign_log, foreign_key: :model_id

  after_create :set_coin

  def get_channel
    CHANNEL[self.channel.to_sym]
  end

  def user_name
    'user_name'
  end

  def share_name
    'shre_name'
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
      company.update coin: company.coin.to_i - coin
      #TODO
      # 游戏剩余金币
    when 'cash'
      user.update coin: user.coin.to_i - coin
    end
  end

end
