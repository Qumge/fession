require 'openssl'
require 'base64'
module V1
  module Entities
    class Reply < Grape::Entity
      format_with(:timestamp) { |dt| dt.try :strftime, '%Y-%m-%d %H:%M:%S' }
      expose :id
      expose :user, using: V1::Entities::User
      expose :questionnaire, using: V1::Entities::Questionnaire
      expose :answers, using: V1::Entities::Answer
      with_options(format_with: :timestamp) do
        expose :created_at, documentation: { type: 'Timestamp' }
        expose :updated_at, documentation: { type: 'Timestamp' }
      end
    end
  end
end