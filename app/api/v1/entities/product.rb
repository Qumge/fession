module V1
  module Entities
    class Product < Grape::Entity
      format_with(:timestamp) { |dt| dt.try :strftime, '%Y-%m-%d %H:%M:%S' }
      expose :id
      expose :name
      expose :type
      expose :status
      expose :get_status
      expose :price do |instance, options|
        instance.type == 'CoinProduct' ? instance.price : (instance.price.to_f / 100)
      end
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
      expose :specs, using: V1::Entities::Spec

      with_options(format_with: :timestamp) do
        expose :created_at
        expose :updated_at
      end
    end
  end
end