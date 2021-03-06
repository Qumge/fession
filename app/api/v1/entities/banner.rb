module V1
  module Entities
    class Banner < Grape::Entity
      format_with(:timestamp) { |dt| dt.try :strftime, '%Y-%m-%d %H:%M:%S' }
      expose :id
      expose :no
      expose :image, using: V1::Entities::Image
      expose :task, using: V1::Entities::Task, if: proc{|instance| instance.type != 'Banner::PostBanner'}
      expose :post, using: V1::Entities::Post, if: proc{|instance| instance.type == 'Banner::PostBanner'}
      with_options(format_with: :timestamp) do
        expose :created_at, documentation: { type: 'Timestamp' }
        expose :updated_at, documentation: { type: 'Timestamp' }
      end
    end
  end
end