module V1
  module Entities
    class Product < Grape::Entity
      format_with(:timestamp) { |dt| dt.try :strftime, '%Y-%m-%d %H:%M:%S' }
      expose :id
      expose :name
      expose :type
      expose :status
      expose :get_status
      expose :failed_reason
      expose :task_id do |instance, options|
        instance.task_product_task&.id
      end
      expose :h5_link
      expose :price do |instance, options|
        instance.view_price
      end
      expose :no
      expose :stock
      expose :sale
      expose :coin
      expose :view_num
      expose :sale_coin
      expose :amount
      expose :desc do |instance, options|
        instance.desc.to_s
      end
      expose :default_image

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