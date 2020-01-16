module V1
  module Admins
    class Roles < Grape::API
      helpers V1::Admins::AdminLoginHelper
      include Grape::Kaminari
      resources 'roles' do


        before do
          authenticate!
          operator_auth!
        end


        desc '当前角色权限', {
            headers: {
                "X-Auth-Token" => {
                    description: "登录token",
                    required: false
                }
            }
        }
        get 'resources' do
          if @current_admin.role.present?
            present @current_admin.role, with: V1::Entities::Role
          else
            present Role.new, with: V1::Entities::Role
          end
        end

        desc '角色权限列表', {
            headers: {
                "X-Auth-Token" => {
                    description: "登录token",
                    required: false
                }
            }
        }

        params do
          optional :page,     type: Integer, default: 1, desc: '页码'
          optional :per_page, type: Integer, desc: '每页数据个数', default: Settings.per_page
          optional :search, type: String, desc: '搜索内容'
        end
        get '/' do
          roles = Role.search_conn(params).order('updated_at desc')
          present paginate(roles), with: V1::Entities::Role
        end


        desc '创建角色', {
            headers: {
                "X-Auth-Token" => {
                    description: "登录token",
                    required: false
                }
            }
        }
        params do
          requires 'name', type: String, desc: '角色名'
          optional 'resource_names', type: String , desc: '权限名集合转成json: ["商品管理", "商家商品", ..]', default: []
        end
        post '/' do
          role = Role.new name: params[:name]
          resources = []
          JSON.parse(params[:resource_names]).each do |name|
            resources << Resource.find_or_initialize_by(name: name)
          end
          role.resources = resources
          if role.save
            present role, with: V1::Entities::Role
          else
            {error: '10002', message: role.view_errors}
          end
        end


        route_param :id do
          before do
            @role = Role.find_by id: params[:id]
            error!("找不到数据", 500) unless @role.present?
          end

          desc '角色变更', {
              headers: {
                  "X-Auth-Token" => {
                      description: "登录token",
                      required: false
                  }
              }
          }
          params do
            optional 'name', type: String, desc: '角色名'
            optional 'resource_names', type: String , desc: '权限名集合: ["商品管理", "商家商品", ..]', default: []
          end
          patch '/' do
            resources = []
            JSON.parse(params[:resource_names]).each do |name|
              resources << Resource.find_or_initialize_by(name: name)
            end
            @role.resources = resources
            @role.name = params[:name] if params[:name].present?
            if @role.save
              present @role, with: V1::Entities::Role
            else
              {error: '10002', message: role.view_errors}
            end
          end


          desc '角色详情', {
              headers: {
                  "X-Auth-Token" => {
                      description: "登录token",
                      required: false
                  }
              }
          }
          get '/' do
            present @role, with: V1::Entities::Role
          end

          desc '删除角色', {
              headers: {
                  "X-Auth-Token" => {
                      description: "登录token",
                      required: false
                  }
              }
          }
          delete '/' do
            if @role.destroy
              {error: '', message: '删除成功'}
            else
              {error: '30001', message: '删除失败'}
            end
          end

        end



      end
    end
  end
end