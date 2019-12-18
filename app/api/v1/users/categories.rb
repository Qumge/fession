module V1
  module Admins
    class Categories < Grape::API
      helpers V1::Users::AdminLoginHelper
      include Grape::Kaminari
      resources 'categories' do

        desc '分类列表'
        get '/' do
          categories = Category.roots.order('updated_at desc')
          present categories, with: V1::Entities::CategoryTree
        end
      end
    end
  end
end