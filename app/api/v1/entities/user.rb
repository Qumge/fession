module V1
  module Entities
    class User < Grape::Entity
      format_with(:timestamp) { |dt| dt.try :strftime, '%Y-%m-%d %H:%M:%S' }
      expose :id
      expose :login
      expose :coin
      expose :country
      expose :province
      expose :city
      expose :avatar_url
      expose :nick_name
      expose :gender
      expose :view_num
      expose :following_num do
        1000
      end
      expose :follower_num do
        2000
      end


      # product_category 是在rails的model中定义的关联，在这里可以直接用
      #expose :role, using: V1::Entities::Role

      with_options(format_with: :timestamp) do
        expose :created_at, documentation: { type: 'Timestamp' }
        expose :updated_at, documentation: { type: 'Timestamp' }
      end
    end
  end
end