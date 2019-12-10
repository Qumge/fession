module V1
  module Entities
    class FissionLog < Grape::Entity
      format_with(:timestamp) { |dt| dt.try :strftime, '%Y-%m-%d %H:%M:%S' }
      expose :id
      expose :token
      expose :share_url do |instance, options|
        URI::encode "#{Settings.h5_url}/pages/task/show?id=#{instance.task_id}&token=#{instance.token}"
      end
      expose :parent, using: V1::Entities::FissionLog
      expose :user, using: V1::Entities::User
      expose :task, using: V1::Entities::Task


      # product_category 是在rails的model中定义的关联，在这里可以直接用
      #expose :company, using: V1::Entities::Company

      with_options(format_with: :timestamp) do
        expose :created_at, documentation: { type: 'Timestamp' }
        expose :updated_at, documentation: { type: 'Timestamp' }
      end
    end
  end
end