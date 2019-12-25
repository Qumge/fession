require 'openssl'
require 'base64'
module V1
  module Entities
    class Payment < Grape::Entity
      format_with(:timestamp) { |dt| dt.try :strftime, '%Y-%m-%d %H:%M:%S' }
      expose :status
      expose :amount
      expose :prepay_id
      expose :user, using: V1::Entities::User
      expose :js_pay
      with_options(format_with: :timestamp) do
        expose :created_at, documentation: { type: 'Timestamp' }
        expose :updated_at, documentation: { type: 'Timestamp' }
      end
    end
  end
end