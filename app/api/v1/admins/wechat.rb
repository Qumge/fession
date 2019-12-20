module V1
  module Admins
    class Wechat < Grape::API
      format :xml
      content_type :xml, "text/xml"
      resources 'wechat' do
        desc '微信订单支付结果'
        post 'notify' do
          result = params["xml"]
          company_payment = CompanyPayment.find_by no: result['out_trade_no']['__content__']
          company_payment.update response_data: result
          company_payment.do_pay! if company_payment.may_do_pay?
          p company_payment, 333
          status 200
          {return_code: "SUCCESS"}
        end
        
      end
    end
  end
end
