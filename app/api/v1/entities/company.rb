module V1
  module Entities
    class Company < Grape::Entity
      format_with(:timestamp) { |dt| dt.try :strftime, '%Y-%m-%d %H:%M:%S' }
      expose :id
      expose :name
      expose :no
      expose :status
      expose :coin
      expose :follow do |instance, options|
        user = options[:user]
        if user.present? && user.follow_companies.where(id: instance.id).present?
          1
        else
          0
        end
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