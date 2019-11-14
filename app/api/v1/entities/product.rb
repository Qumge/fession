module V1
  module Entities
    class Product < Grape::Entity
      format_with(:timestamp) { |dt| dt.try :strftime, '%Y-%m-%d %H:%M:%S' }
      expose :id
      expose :name
      expose :type
      expose :status do |instance, options|
        # examine available environment keys with `p options[:env].keys`
        instance.get_status
      end
      expose :price
      expose :no
      expose :stock
      expose :sale
      expose :coin
      expose :desc

      # product_category 是在rails的model中定义的关联，在这里可以直接用
      expose :company, using: V1::Entities::Company
      expose :category, using: V1::Entities::Category
      expose :norms, using: V1::Entities::Norm
      expose :images, using: V1::Entities::Image

      with_options(format_with: :timestamp) do
        expose :created_at
        expose :updated_at
      end
    end
  end
end