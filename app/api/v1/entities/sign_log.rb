module V1
  module Entities
    class SignLog < Grape::Entity
      format_with(:timestamp) { |dt| dt.try :strftime, '%Y-%m-%d %H:%M:%S' }
      expose :id
      expose :days
      expose :user, using: V1::Entities::User
      with_options(format_with: :timestamp) do
        expose :sign_at
        expose :created_at
        expose :updated_at
      end
    end
  end
end