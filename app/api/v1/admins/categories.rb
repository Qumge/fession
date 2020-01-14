module V1
  module Admins
    class Categories < Grape::API
      helpers V1::Admins::AdminLoginHelper
      include Grape::Kaminari
      resources 'categories' do

        desc '分类列表', {
            headers: {
                "X-Auth-Token" => {
                    description: "登录token",
                    required: false
                }
            }
        }
        get '/' do
          categories = Category.roots.order('updated_at desc')
          present categories, with: V1::Entities::CategoryTree
        end

        before do
          authenticate!
          operator_auth!
        end
        desc '创建分类', {
            headers: {
                "X-Auth-Token" => {
                    description: "登录token",
                    required: false
                }
            }
        }
        params do
          requires 'name', type: String, desc: '分类名'
          optional 'root_id', type: Integer, desc: '上级分类id'
        end
        post '/' do
          operator_auth!
          category = Category.new name: params[:name]
          if params[:root_id].present?
            root = Category.find_by id: params[:root_id]
            if root.present? && root.is_root?
              category.parent = root
            else
              return {error: '10002', message: '错误的上级分类'}
            end
          end
          if category.save
            present category, with: V1::Entities::Category
          else
            {error: '20001', message: category.errors.messages&.values&.first&.first}
          end
        end


        route_param :id do
          before do
            @category = Category.find_by id: params[:id]
            error!("找不到数据", 500) unless @category.present?
          end
          desc '分类变更', {
              headers: {
                  "X-Auth-Token" => {
                      description: "登录token",
                      required: false
                  }
              }
          }
          params do
            requires 'name', type: String, desc: '分类名'
            optional 'root_id', type: Integer, desc: '上级分类id'
          end
          patch '/' do
            operator_auth!
            @category.name = params[:name]
            if params[:root_id].present?
              root = Category.find_by id: params[:root_id]
              if root.present? && root.is_root?
                @category.parent = root
              else
                return {error: '10002', message: '错误的上级分类'}
              end
            else
              @category.parent = nil
            end
            if @category.save
              present @category, with: V1::Entities::Category
            else
              {error: '20001', message: @category.errors.messages&.values&.first&.first}
            end
          end

          desc '分类删除', {
              headers: {
                  "X-Auth-Token" => {
                      description: "登录token",
                      required: false
                  }
              }
          }
          delete '/' do
            if @category.has_children? || @category.products.present?
              {error: '30002', message: '删除失败，该分类有子节点或商品'}
            else
              if @category.destroy
                {error: '', message: '删除成功'}
              else
                {error: '30001', message: '删除失败'}
              end
            end

          end


          desc '分类详情', {
              headers: {
                  "X-Auth-Token" => {
                      description: "登录token",
                      required: false
                  }
              }
          }
          get '/' do
            present @category, with: V1::Entities::Category
          end

        end



      end
    end
  end
end