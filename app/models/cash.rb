class Cash < ApplicationRecord
  include AASM
  belongs_to :user
  has_many :audit_cash_audits, :class_name => 'Audit::CashAudit', foreign_key: :model_id
  after_create :cut_coin

  STATUS = { wait: '待审核', failed: '已拒绝', success: '已同意', done: '已提现'}

  aasm :status do
    state :wait, :initial => true
    state :failed, :success, :done

    # # 申请审核
    # event :do_wait do
    #   transitions :from => :new, :to => :wait
    # end

    # 审核成功
    event :do_success do
      transitions :from => :wait, :to => :success
    end


    #审核失败
    event :do_failed do
      transitions :from => :wait, :to => :failed, after: Proc.new {add_coin}
    end

    #审核失败
    event :do_done do
      transitions :from => :success, :to => :done
    end
  end

  def add_coin
    CoinLog.create channel: 'failed_cash', coin: coin, user: user
  end

  def cut_coin
    p 111111111111
    CoinLog.create channel: 'cash', coin: coin - 2*coin, user: user
  end

  def fetch_params params
    cash_rule = CashRule.first
    if cash_rule.present?
      if params[:amount] >= cash_rule.floor
        if self.user.coin.to_i >= params[:amount] * cash_rule.coin
          self.update coin: params[:amount] * cash_rule.coin, amount: params[:amount]
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
