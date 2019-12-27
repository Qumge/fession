module V1
  module Entities
    class PrizeLog < Grape::Entity
      format_with(:timestamp) { |dt| dt.try :strftime, '%Y-%m-%d %H:%M:%S' }
      expose :id
      expose :game, using: V1::Entities::Game
      expose :user, using: V1::Entities::User
      expose :prize, using: V1::Entities::Prize
      with_options(format_with: :timestamp) do
        expose :created_at, documentation: { type: 'Timestamp' }
        expose :updated_at, documentation: { type: 'Timestamp' }
      end
    end
  end
end