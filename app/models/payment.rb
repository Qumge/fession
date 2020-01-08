# == Schema Information
#
# Table name: payments
#
#  id              :bigint           not null, primary key
#  amount          :integer
#  apply_res       :text(65535)
#  no              :string(255)
#  refund_response :text(65535)
#  response_data   :text(65535)
#  status          :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  order_id        :integer
#  prepay_id       :string(255)
#  transaction_id  :string(255)
#  user_id         :integer
#

class Payment < ApplicationRecord
  # has_and_belongs_to_many :orders, join_table: 'order_payments'
  belongs_to :order
  belongs_to :user
  include AASM
  after_create :unifiedorder

  STATUS = {wait: '新数据', apply: '微信下单', pay: '支付成功', refund: '已退款'}
  aasm :status do
    state :wait, :initial => true
    state :apply, :pay, :refund

    #审核成功 直接上架
    event :do_apply do
      transitions :from => [:wait], :to => :apply
    end

    #审核失败
    event :do_pay do
      transitions :from => :apply, :to => :pay
    end

    #审核失败
    event :do_refund do
      transitions :from => :pay, :to => :refund
    end

  end

  def js_pay
    if self.prepay_id.present?
      WxPay.appid = self.appid
      params = {prepayid: self.prepay_id, noncestr: SecureRandom.hex(16), }
      WxPay::Service.generate_js_pay_req params
    end

  end

  def app_pay
    if self.prepay_id.present?
      WxPay.appid = self.appid
      params = {prepayid: self.prepay_id, noncestr: SecureRandom.hex(16), }
      WxPay::Service.generate_app_pay_req params
    end
  end

  def order_query
    p self.appid, 111
    WxPay.appid = self.appid
    params = {out_trade_no: self.order.no}
    res = WxPay::Service.order_query params
    if res[:raw].present? && res[:raw]['xml'].present? && res[:raw]['xml']['return_code'] == 'SUCCESS'
      self.update response_data: res[:raw]['xml'], transaction_id: res[:raw]['xml']['transaction_id']
      self.do_pay! if self.may_do_pay?
      self.order.do_pay! if self.order.may_do_pay?
    end
    self
  end

  def appid
    if self.apply_res
      JSON.parse(self.apply_res)['appid']
    end
  end

  def times_order_query times = 5
    p 'time pay'
    times.times do |time|
      payment = self.order_query
      break if payment.pay?
      sleep 2
    end
  end

  def order_pay
    self.order.do_pay! if self.order.may_do_pay?
  end

  def unifiedorder
    if self.order.platform == 'app'
      WxPay.appid = Settings.app_appid
    else
      WxPay.appid = Settings.web_appid
    end
    trade_type = self.order.platform == 'app' ? 'APP' : 'JSAPI'
    params = {
        body: '裂变商城',
        out_trade_no: self.order.no,
        total_fee: 1, #amount
        spbill_create_ip: '127.0.0.1',
        notify_url: Settings.user_notify_url,
        trade_type: trade_type,
    }
    unless self.order.platform == 'app'
      params[:openid] = user.web_openid
    end
    p params, 111
    payment_logger.info '========beigin unfiedorder============'
    r = WxPay::Service.invoke_unifiedorder params
    if r.success?
      self.do_apply! if self.may_do_apply?
      self.update apply_res: r[:raw]['xml'].to_json, prepay_id: r[:raw]['xml']['prepay_id']
    else
      payment_logger.info "=========unfiedorder error #{r}=============="
    end
  end

  def refund_money
    params = {
        transaction_id: self.transaction_id,
        out_refund_no: self.order.no,
        total_fee: 1,
        refund_fee: 1
    }
    # WxPay::Service.invoke_refund params
    # todu
    p params, 111
    if self.order.platform == 'app'
      WxPay.appid = Settings.app_appid
    else
      WxPay.appid = Settings.web_appid
    end
    res = WxPay::Service.invoke_refund params
    if res[:raw].present? && res[:raw]['xml'].present?
      self.update refund_response: res[:raw]['xml']
      if res[:raw]['xml']['result_code'] == 'SUCCESS'
        self.do_refund! if self.may_do_refund?
        self.order.after_order.do_refund! if self.order.after_order.may_do_refund?
      end
    end
    res
  end

  def payment_logger
    Logger.new 'log/user_payment.log'
  end
end
