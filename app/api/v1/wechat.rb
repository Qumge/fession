module V1
  class Wechat < Grape::API
    format :xml
    content_type :xml, "text/xml"
    resources 'wechat' do
      desc '微信订单支付结果'
      post 'company_notify' do
        p params, 2222
        result = params["xml"]
        p result, 111
        company_payment = CompanyPayment.find_by no: result['out_trade_no']['__content__']
        if company_payment.present?
          company_payment.times_order_query
        end
        p company_payment, 333
        status 200
        {return_code: "SUCCESS"}
      end

      desc '微信订单支付结果'
      post 'user_notify' do
        p params, 2222
        result = params["xml"]

        order = Order.find_by no: result['out_trade_no']['__content__']
        if order.present?
          order.current_payment.times_order_query
        end
        status 200
        {return_code: "SUCCESS"}
      end
    end
  end
end
