module V1
  module Admins
    class Categories < Grape::API
      helpers V1::Admins::AdminLoginHelper
      include Grape::Kaminari
      resources 'categories' do

        before do
          authenticate!
        end


        desc '分类列表', {
            headers: {
                "X-Auth-Token" => {
                    description: "登录token",
                    required: false
                }
            }
        }
        params do
          optional 'page', type: String, desc: '页码', default: 1
          optional 'per_page', type: String, desc: '单页数量'
          optional :page,     type: Integer, default: 1, desc: '页码'
          optional :per_page, type: Integer, desc: '每页数据个数', default: Settings.per_page
        end
        get '/' do
          categories = Category.roots.order('updated_at desc')
          present paginate(categories), with: V1::Entities::CategoryTree
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
              return {error_code: '10002', error_message: '错误的上级分类'}
            end
          end
          if category.save
            present category, with: V1::Entities::Category
          else
            {error_code: '00000', error_message: category.errors.messages}
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
                return {error_code: '10002', error_message: '错误的上级分类'}
              end
            else
              @category.parent = nil
            end
            if @category.save
              present @category, with: V1::Entities::Category
            else
              {error_code: '00000', error_message: @category.errors.messages}
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