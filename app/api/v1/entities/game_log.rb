module V1
  module Entities
    class GameLog < Grape::Entity
      format_with(:timestamp) { |dt| dt.try :strftime, '%Y-%m-%d %H:%M:%S' }
      expose :id
      expose :coin
      expose :game, using: V1::Entities::Game
      expose :user, using: V1::Entities::User
      expose :prize_log, using: V1::Entities::PrizeLog
      with_options(format_with: :timestamp) do
        expose :created_at
        expose :updated_at
      end
    end
  end
end