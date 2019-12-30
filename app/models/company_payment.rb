class CompanyPayment < ApplicationRecord

  belongs_to :company
  after_create_commit :unifiedorder
  before_create :set_no

  include AASM

  STATUS = { wait: '新数据', apply: '微信下单', pay: '支付成功'}

  aasm :status do
    state :wait, :initial => true
    state :apply, :pay


    event :do_apply do
      transitions :from => [:wait], :to => :apply
    end


    event :do_pay do
      transitions :from => :apply, :to => :pay
    end

  end


  def set_no
    self.no = "#{self.company.no.to_s[0..3] if self.company.present?}#{Time.now.to_i}#{rand(1000..9999)}"
    cash_rule = CashRule.first
    if cash_rule.present?
      self.coin = cash_rule.coin * amount / 100
    else
      self.coin = cash_rule.coin * amount / 100
    end

  end

  def order_query
    params = {out_trade_no: self.order.no}
    res = WxPay::Service.order_query params
    if res[:raw].present? && res[:raw]['return_code'] == 'SUCCESS'
      self.update response_data: result
      self.do_pay! if self.may_do_pay?
    end
    self
  end




  def times_order_query times=5
    times.times do |time|
      payment = self.order_query
      break if payment.pay?
      sleep 2000
    end
  end

  def unifiedorder
    params = {
        body: '金币充值',
        out_trade_no: self.no,
        total_fee: 1, #amount
        spbill_create_ip: '127.0.0.1',
        notify_url: Settings.company_notify_url,
        trade_type: 'NATIVE'
    }
    p 11111
    payment_logger.info '========beigin unfiedorder============'
    r = WxPay::Service.invoke_unifiedorder params
    p r, 222
    if r.success?
      self.do_apply! if self.may_do_apply?
      self.update apply_res: r[:raw]['xml'].to_json, prepay_id: r[:raw]['xml']['prepay_id'], qrcode: r[:raw]['xml']['code_url']
    else
      payment_logger.info "=========unfiedorder error #{r}=============="
    end
  end

  def payment_logger
    Logger.new 'log/payment.log'
  end



  class << self
    def test
      params = {
          body: '金币充值',
          out_trade_no: 'test003',
          total_fee: 1,
          spbill_create_ip: '127.0.0.1',
          notify_url: 'http://making.dev/notify',
          trade_type: 'NATIVE'
      }

      params = {
          body: 'ewewew',
          out_trade_no: '11199900',
          total_fee: 1,
          spbill_create_ip: '127.0.0.1',
          notify_url: 'https://api.shjietui.com/api/v1/open_weixin/order_notify',
          trade_type: 'NATIVE', # could be "MWEB", ""JSAPI", "NATIVE" or "APP",
          # openid: 'oDyUC1qauYCi4tje6NvKmrZ8n4WA' # required when trade_type is `JSAPI`
      }

      r = WxPay::Service.invoke_unifiedorder params
      r
    end
  end
end
