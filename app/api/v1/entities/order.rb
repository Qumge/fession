module V1
  module Entities
    class Order < Grape::Entity
      format_with(:timestamp) { |dt| dt.try :strftime, '%Y-%m-%d %H:%M:%S' }
      expose :id
      expose :type
      expose :no
      expose :user, using: V1::Entities::User
      expose :company, using: V1::Entities::Company
      expose :logistic, using: V1::Entities::Logistic
      expose :order_products, using: V1::Entities::OrderProduct
      expose :address, using: V1::Entities::Address
      expose :current_payment, using: V1::Entities::Payment
      expose :after_order, using: V1::Entities::AfterOrder
      expose :prize_log, using: V1::Entities::PrizeLog
      expose :view_amount
      expose :status
      expose :coin
      expose :number
      expose :express_no
      expose :get_express_type
      expose :get_status
      expose :get_status_desc
      with_options(format_with: :timestamp) do
        expose :payment_at, documentation: { type: 'Timestamp' }
        expose :created_at, documentation: { type: 'Timestamp' }
        expose :updated_at, documentation: { type: 'Timestamp' }
      end
    end
  end
end