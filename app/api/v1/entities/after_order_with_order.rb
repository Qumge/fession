module V1
  module Entities
    class AfterOrderWithOrder < Grape::Entity
      format_with(:timestamp) { |dt| dt.try :strftime, '%Y-%m-%d %H:%M:%S' }
      expose :id
      expose :type
      expose :status
      expose :get_status
      expose :get_express_type
      expose :express_type
      expose :express_no
      expose :order, using: V1::Entities::Order
      with_options(format_with: :timestamp) do
        expose :created_at, documentation: { type: 'Timestamp' }
        expose :updated_at, documentation: { type: 'Timestamp' }
      end
    end
  end
end