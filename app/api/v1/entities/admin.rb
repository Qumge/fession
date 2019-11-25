module V1
  module Entities
    class Admin < Grape::Entity
      format_with(:timestamp) { |dt| dt.try :strftime, '%Y-%m-%d %H:%M:%S' }
      expose :id
      expose :login
      expose :type
      expose :role_type
      expose :name
      expose :status
      expose :get_status
      # product_category 是在rails的model中定义的关联，在这里可以直接用
      expose :role, using: V1::Entities::Role
      expose :company, using: V1::Entities::Company

      with_options(format_with: :timestamp) do
        expose :created_at, documentation: { type: 'Timestamp' }
        expose :updated_at, documentation: { type: 'Timestamp' }
      end
    end
  end
end