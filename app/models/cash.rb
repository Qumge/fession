# == Schema Information
#
# Table name: cashes
#
#  id            :bigint           not null, primary key
#  amount        :integer
#  bank_code     :string(255)
#  coin          :integer
#  enc_bank_no   :string(255)
#  enc_true_name :string(255)
#  status        :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  user_id       :integer
#

class Cash < ApplicationRecord
  include AASM
  belongs_to :user
  has_many :audit_cash_audits, :class_name => 'Audit::CashAudit', foreign_key: :model_id
  after_create :cut_coin

  STATUS = { wait: '待审核', failed: '已拒绝', success: '打款中', done: '已到账'}
  BANK = {"1002"=>"工商银行", "1005"=>"农业银行", "1003"=>"建设银行", "1026"=>"中国银行", "1020"=>"交通银行", "1001"=>"招商银行", "1066"=>"邮储银行", "1006"=>"民生银行", "1010"=>"平安银行", "1021"=>"中信银行", "1004"=>"浦发银行", "1009"=>"兴业银行", "1022"=>"光大银行", "1027"=>"广发银行", "1025"=>"华夏银行", "1056"=>"宁波银行", "4836"=>"北京银行", "1024"=>"上海银行", "1054"=>"南京银行"}
  aasm :status do
    state :wait, :initial => true
    state :failed, :success, :done

    # # 申请审核
    # event :do_wait do
    #   transitions :from => :new, :to => :wait
    # end

    # 审核成功
    event :do_success do
      transitions :from => :wait, :to => :success, after: Proc.new {pay_bank}
    end


    #审核失败
    event :do_failed do
      transitions :from => :wait, :to => :failed, after: Proc.new {add_coin}
    end

    #打款成功
    event :do_done do
      transitions :from => :success, :to => :done
    end
  end

  def pay_bank

  end

  def add_coin
    CoinLog.create channel: 'failed_cash', coin: coin, user: user
  end

  def cut_coin
    CoinLog.create channel: 'cash', coin: coin - 2*coin, user: user
  end

  def bank
    BANK[self.bank_code] if self.bank_code.present?
  end

  def get_status
    STATUS[self.status.to_sym] if self.status.present?
  end

  def fetch_params params
    cash_rule = CashRule.first
    if cash_rule.present?
      if params[:amount] >= cash_rule.floor
        if self.user.coin.to_i >= params[:amount] * cash_rule.coin
          self.update coin: params[:amount] * cash_rule.coin, amount: params[:amount], bank_code: params[:bank_code], enc_bank_no: params[:enc_bank_no], enc_true_name: params[:enc_true_name]
        else
          self.errors.add :amount, '金币不足'
        end
      else
        self.errors.add :amount, '不符合提现规则'
      end
    else
      self.errors.add :amount, '不符合提现规则'
    end
    self

  end
end
