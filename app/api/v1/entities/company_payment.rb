require 'openssl'
require 'base64'
module V1
  module Entities
    class CompanyPayment < Grape::Entity
      format_with(:timestamp) { |dt| dt.try :strftime, '%Y-%m-%d %H:%M:%S' }
      expose :status
      expose :amount do |instance, options|
        instance.amount.to_f / 100 if instance.amount.present?
      end
      expose :coin
      expose :pay_type do |instance, options|
        '微信支付'
      end

      expose :prepay_id
      expose :qrcode
      expose :company, using: V1::Entities::Company
      with_options(format_with: :timestamp) do
        expose :created_at, documentation: { type: 'Timestamp' }
        expose :updated_at, documentation: { type: 'Timestamp' }
      end
    end
  end
end