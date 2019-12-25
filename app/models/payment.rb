class Payment < ApplicationRecord
  # has_and_belongs_to_many :orders, join_table: 'order_payments'
  belongs_to :order
  belongs_to :user
  include AASM
  after_create :unifiedorder

  STATUS = { wait: '新数据', apply: '微信下单', pay: '支付成功'}
  aasm :status do
    state :wait, :initial => true
    state :apply, :pay

    #审核成功 直接上架
    event :do_apply do
      transitions :from => [:wait], :to => :apply
    end

    #审核失败
    event :do_pay do
      transitions :from => :apply, :to => :pay
    end

  end

  def js_pay
    params = {prepayid: self.prepay_id, noncestr: SecureRandom.hex(16), }
    WxPay::Service.generate_js_pay_req params
  end

  def unifiedorder
    params = {
        body: '裂变商城',
        out_trade_no: self.order.no,
        total_fee: 1, #amount
        spbill_create_ip: '127.0.0.1',
        notify_url: Settings.notify_url+ "?type=user",
        trade_type: 'JSAPI',
        openid: user.web_openid
    }
    payment_logger.info '========beigin unfiedorder============'
    r = WxPay::Service.invoke_unifiedorder params
    p r, 222
    if r.success?
      p r, 1111
      self.do_apply! if self.may_do_apply?
      self.update apply_res: r[:raw]['xml'].to_json, prepay_id: r[:raw]['xml']['prepay_id']
    else
      payment_logger.info "=========unfiedorder error #{r}=============="
    end
  end

  def payment_logger
    Logger.new 'log/user_payment.log'
  end
end
