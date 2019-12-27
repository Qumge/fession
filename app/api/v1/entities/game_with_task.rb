module V1
  module Entities
    class GameWithTask < Grape::Entity
      format_with(:timestamp) { |dt| dt.try :strftime, '%Y-%m-%d %H:%M:%S' }
      expose :id
      expose :name
      expose :cost
      expose :coin
      expose :desc
      expose :type
      expose :prize_user_num
      expose :prize_coin
      expose :prize_product_num
      expose :image, using: V1::Entities::Image
      expose :h5_link
      expose :prizes, using: V1::Entities::Prize
      expose :task_game_task, using: V1::Entities::Task
      with_options(format_with: :timestamp) do
        expose :created_at
        expose :updated_at
      end
    end
  end
end