module V1
  module Entities
    class Article < Grape::Entity
      format_with(:timestamp) { |dt| dt.try :strftime, '%Y-%m-%d %H:%M:%S' }
      expose :id
      expose :subject
      expose :content
      expose :view_num
      expose :product, using: V1::Entities::Product
      with_options(format_with: :timestamp) do
        expose :created_at
        expose :updated_at
      end
    end
  end
end