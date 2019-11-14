module V1
  module Entities
    class Category < Grape::Entity
      format_with(:timestamp) { |dt| dt.try :strftime, '%Y-%m-%d %H:%M:%S' }
      #format_with(:parent) { |dt| instance.parent.name }
      expose :id
      expose :name

      # product_category 是在rails的model中定义的关联，在这里可以直接用
      expose :parent, using: V1::Entities::Category

      with_options(format_with: :timestamp) do
        expose :created_at
        expose :updated_at
      end
    end
  end
end