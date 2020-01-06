# == Schema Information
#
# Table name: sign_logs
#
#  id         :bigint           not null, primary key
#  days       :integer          default(1)
#  sign_at    :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :integer
#

class SignLog < ApplicationRecord

  belongs_to :user
  after_create :set_sign_coin

  class << self

    def search_conn params

      logs = self.all
      if params[:date_from].present?
        logs = logs.where('sign_at >= ? ', params[:date_from].to_datetime)
      end
      if params[:date_to].present?
        logs = logs.where('sign_at < ? ', params[:date_to].to_datetime.end_of_day)
      end
      logs
    end

    def sign user
      last_sign_log = user.sign_log
      if last_sign_log
        #如果当天签到
        if last_sign_log.sign_at >= DateTime.now.beginning_of_day && last_sign_log.sign_at < DateTime.now.end_of_day
          last_sign_log
          # 如果前一天签到
        elsif last_sign_log.sign_at >= (DateTime.now - 1.days).beginning_of_day && last_sign_log.sign_at < (DateTime.now - 1.days).end_of_day
          user.sign_logs.create sign_at: DateTime.now, days: last_sign_log.days + 1
        else
          user.sign_logs.create sign_at: DateTime.now
        end
      else
        user.sign_logs.create sign_at: DateTime.now
      end
    end
  end


  def set_sign_coin
    #最大签到天数
    max_days = SignRule.maximum :number
    if max_days
      days = self.days%max_days == 0 ? max_days : self.days%max_days
      sign_rule = SignRule.find_by number: days
      if sign_rule
        CoinLog.create user: user, channel: 'sign', coin: sign_rule.coin, model_id: self.id
      else
        sign_rule = SignRule.find_by number: 1
        if sign_rule
          CoinLog.create user: user, channel: 'sign', coin: sign_rule.coin, model_id: self.id
        end
      end
    end

  end


end
