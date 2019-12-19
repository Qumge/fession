module V1
  module Entities
    class Order < Grape::Entity
      format_with(:timestamp) { |dt| dt.try :strftime, '%Y-%m-%d %H:%M:%S' }
      expose :id
      expose :type
      expose :no
      expose :user, using: V1::Entities::User
      expose :company, using: V1::Entities::Company
      expose :order_products, using: V1::Entities::OrderProduct
      with_options(format_with: :timestamp) do
        expose :created_at, documentation: { type: 'Timestamp' }
        expose :updated_at, documentation: { type: 'Timestamp' }
      end
    end
  end
end