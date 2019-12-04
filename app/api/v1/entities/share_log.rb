module V1
  module Entities
    class ShareLog < Grape::Entity
      format_with(:timestamp) { |dt| dt.try :strftime, '%Y-%m-%d %H:%M:%S' }
      expose :user, using: V1::Entities::User
      expose :fission_log, using: V1::Entities::FissionLog
      with_options(format_with: :timestamp) do
        expose :created_at
        expose :updated_at
      end
    end
  end
end