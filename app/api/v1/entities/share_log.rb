module V1
  module Entities
    class ShareLog < Grape::Entity
      format_with(:timestamp) { |dt| dt.try :strftime, '%Y-%m-%d %H:%M:%S' }
      expose :id
      expose :task_name
      expose :fission_log_id
      expose :token
      expose :user_id
      expose :user_name
      with_options(format_with: :timestamp) do
        expose :created_at
        expose :updated_at
      end
    end
  end
end