class CompanyPayment < ApplicationRecord

  class << self
    def test
      params = {
          body: '测试商品',
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
