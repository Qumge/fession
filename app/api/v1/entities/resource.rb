module V1
  module Entities
    class Resource < Grape::Entity
      format_with(:timestamp) { |dt| dt.try :strftime, '%Y-%m-%d %H:%M:%S' }
      expose :id
      expose :name

      # product_category 是在rails的model中定义的关联，在这里可以直接用

      with_options(format_with: :timestamp) do
        expose :created_at, documentation: { type: 'Timestamp' }
        expose :updated_at, documentation: { type: 'Timestamp' }
      end
    end
  end
end