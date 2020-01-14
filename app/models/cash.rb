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
#  no            :string(255)
#  pay_at        :datetime
#  pay_status    :string(255)
#  response_data :text(65535)
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

  STATUS = { wait: '待审核', failed: '已拒绝', success: '已通过', done: '已到账'}
  PAY_STATUS = {pay_wait: '审核中', paying: '打款中', pay_failed: '打款失败', pay_success: '打款成功', }
  BANK = {"1002"=>"工商银行", "1005"=>"农业银行", "1003"=>"建设银行", "1026"=>"中国银行", "1020"=>"交通银行", "1001"=>"招商银行", "1066"=>"邮储银行", "1006"=>"民生银行", "1010"=>"平安银行", "1021"=>"中信银行", "1004"=>"浦发银行", "1009"=>"兴业银行", "1022"=>"光大银行", "1027"=>"广发银行", "1025"=>"华夏银行", "1056"=>"宁波银行", "4836"=>"北京银行", "1024"=>"上海银行", "1054"=>"南京银行"}
  aasm :status do
    state :wait, :initial => true
    state :failed, :success, :done

    # # 申请审核
    # event :do_wait do
    #   transitions :from => :new, :to => :wait
    # end

    # 审核成功
    event :do_success, after_commit: :pay_bank do
      transitions :from => :wait, :to => :success
    end


    #审核失败
    event :do_failed do
      transitions :from => :wait, :to => :failed, after: Proc.new {add_coin}
    end

  end

  aasm :pay_status do
    state :pay_wait, :initial => true
    state :pay_failed, :pay_success, :paying

    # # 申请审核
    # event :do_wait do
    #   transitions :from => :new, :to => :wait
    # end

    # 支付中
    event :do_paying do
      transitions :from => [:pay_wait, :pay_failed], :to => :paying
    end

    #
    event :do_pay_failed do
      transitions :from => :paying, :to => :pay_failed
    end

    #打款成功
    event :do_pay_success do
      transitions :from => :paying, :to => :pay_success
    end
  end

  def pay_bank
    #TODO
    
    if self.may_do_paying?
      self.do_paying! 
      params = {
        enc_bank_no: self.enc_bank_no,
        enc_true_name: self.enc_true_name,
        bank_code: self.bank_code,
        amount: self.amount,
        desc: '金币提现',
        partner_trade_no: self.no
      }
      r = WxPay::Service.pay_bank params
      if r[:raw]
        self.update response_data: r[:raw]['xml']
        if r[:result_code] && raw[:result_code] == 'SUCCESS'
          self.do_pay_success! if self.may_do_pay_success?
          self.update pay_at: DateTime.now
        else
          self.do_pay_failed! if self.may_do_pay_failed?
        end
      end
    end
  end

  def add_coin
    CoinLog.create channel: 'failed_cash', coin: coin, user: user
  end

  def cut_coin
    CoinLog.create channel: 'cash', coin: coin - 2*coin, user: user
    self.update no: "C#{DateTime.now.to_i}"
  end

  def bank
    BANK[self.bank_code] if self.bank_code.present?
  end

  def get_status
    STATUS[self.status.to_sym] if self.status.present?
  end

  def get_pay_status
    STATUS[self.pay_status.to_sym] if self.pay_status.present?
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
