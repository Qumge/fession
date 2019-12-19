module V1
  module Entities
    class OrderProduct < Grape::Entity
      format_with(:timestamp) { |dt| dt.try :strftime, '%Y-%m-%d %H:%M:%S' }
      expose :id
      expose :product , using: V1::Entities::Product
      expose :norm, using: V1::Entities::Norm
      # expose :user, using: V1::Entities::User
      expose :view_price
      expose :number
      expose :view_amount
      with_options(format_with: :timestamp) do
        expose :created_at, documentation: { type: 'Timestamp' }
        expose :updated_at, documentation: { type: 'Timestamp' }
      end
    end
  end
end