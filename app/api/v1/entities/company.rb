module V1
  module Entities
    class Company < Grape::Entity
      format_with(:timestamp) { |dt| dt.try :strftime, '%Y-%m-%d %H:%M:%S' }
      expose :id
      expose :name
      expose :no
      expose :status
      expose :coin
      expose :enc_true_name
      expose :bank_code
      expose :bank
      expose :enc_bank_no
      expose :h5_link
      expose :follow do |instance, options|
        user = options[:user]
        if user.present? && user.follow_companies.where(id: instance.id).present?
          1
        else
          0
        end
      end
      expose :total_amount do |instance, options|
        instance.total_amount.to_f / 100
      end
      expose :active_amount do |instance, options|
        instance.active_amount.to_f / 100
      end
      expose :withdraw_amount do |instance, options|
        instance.withdraw_amount.to_f / 100
      end
      expose :invalid_amount do |instance, options|
        instance.invalid_amount.to_f / 100
      end
      expose :return_amount do |instance, options|
        instance.return_amount.to_f / 100
      end
      expose :image, using: V1::Entities::Image

      # product_category 是在rails的model中定义的关联，在这里可以直接用
      expose :customer, using: V1::Entities::Customer

      with_options(format_with: :timestamp) do
        expose :created_at, documentation: { type: 'Timestamp' }
        expose :updated_at, documentation: { type: 'Timestamp' }
      end
    end
  end
end