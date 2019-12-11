require 'openssl'
require 'base64'
module V1
  module Entities
    class Address < Grape::Entity
      format_with(:timestamp) { |dt| dt.try :strftime, '%Y-%m-%d %H:%M:%S' }
      expose :id
      expose :name
      expose :phone
      expose :content
      expose :tag
      expose :send?
      expose :receive?
      expose :user, using: V1::Entities::User
      expose :company, using: V1::Entities::Company
      with_options(format_with: :timestamp) do
        expose :created_at, documentation: { type: 'Timestamp' }
        expose :updated_at, documentation: { type: 'Timestamp' }
      end
    end
  end
end