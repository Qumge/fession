module V1
  module Entities
    class Question < Grape::Entity
      format_with(:timestamp) { |dt| dt.try :strftime, '%Y-%m-%d %H:%M:%S' }
      format_with(:timestamp) { |dt| dt.try :strftime, '%Y-%m-%d' }
      #format_with(:parent) { |dt| instance.parent.name }
      expose :type
      expose :id
      expose :name
      expose :options, using: V1::Entities::Option


      # product_category 是在rails的model中定义的关联，在这里可以直接用
      with_options(format_with: :timestamp) do
        expose :created_at
        expose :updated_at
      end
    end
  end
end