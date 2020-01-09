module V1
  module Entities
    class Cash < Grape::Entity
      format_with(:timestamp) { |dt| dt.try :strftime, '%Y-%m-%d %H:%M:%S' }
      expose :id
      expose :coin
      expose :amount
      expose :enc_true_name
      expose :bank_code
      expose :bank
      expose :enc_bank_no
      expose :status
      expose :get_status
      expose :pay_status
      expose :get_pay_status
      expose :user, using: V1::Entities::User
      # product_category 是在rails的model中定义的关联，在这里可以直接用
      #expose :role, using: V1::Entities::Role
      with_options(format_with: :timestamp) do
        expose :created_at, documentation: { type: 'Timestamp' }
        expose :updated_at, documentation: { type: 'Timestamp' }
      end
    end
  end
end