module V1
  module Entities
    class ShareRule < Grape::Entity
      format_with(:timestamp) { |dt| dt.try :strftime, '%Y-%m-%d %H:%M:%S' }
      expose :id
      expose :level
      expose :level_desc do |instance, options|
        case instance.level
        when 1
          '一级转发'
        when 2
          '二级转发'
        when 3
          '三级转发'
        when 4
          '四级转发'
        end
      end
      expose :coin
      # product_category 是在rails的model中定义的关联，在这里可以直接用
      #expose :role, using: V1::Entities::Role
      with_options(format_with: :timestamp) do
        expose :created_at, documentation: { type: 'Timestamp' }
        expose :updated_at, documentation: { type: 'Timestamp' }
      end
    end
  end
end