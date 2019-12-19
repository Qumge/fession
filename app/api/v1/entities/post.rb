require 'openssl'
require 'base64'
module V1
  module Entities
    class Post < Grape::Entity
      format_with(:timestamp) { |dt| dt.try :strftime, '%Y-%m-%d %H:%M:%S' }
      expose :id
      expose :title
      expose :content
      expose :status
      expose :get_status
      expose :number
      expose :view_num
      expose :user do
        expose :user, merge: true, using: V1::Entities::User
      end

      expose :images, using: V1::Entities::Image
      with_options(format_with: :timestamp) do
        expose :created_at, documentation: { type: 'Timestamp' }
        expose :updated_at, documentation: { type: 'Timestamp' }
      end
    end
  end
end