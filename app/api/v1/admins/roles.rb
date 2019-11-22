module V1
  module Admins
    class Roles < Grape::API
      helpers V1::Admins::AdminLoginHelper
      resources 'roles' do

        before do
          authenticate!
          operator_auth!
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
          optional 'page', type: String, desc: '页码', default: 1
        end
        get '/' do
          roles = Role.order('updated_at desc').page(params[:page]).per(Settings.per_page)
          present roles, with: V1::Entities::Role
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
          optional 'resource_names', type: Array[String] , desc: '权限名集合转成json: ["商品管理", "商家商品", ..]', default: []
        end
        post '/' do
          role = Role.new name: params[:name]
          resources = []
          params[:resource_names].each do |name|
            resources << Resource.find_or_initialize_by(name: name)
          end
          role.resources = resources
          if role.save
            present role, with: V1::Entities::Role
          else
            {error_code: '10002', error_message: role.errors.messages}
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
            requires 'name', type: String, desc: '角色名'
            optional 'resource_names', type: Array[String] , desc: '权限名集合: ["商品管理", "商家商品", ..]', default: []
          end
          patch '/' do
            resources = []
            params[:resource_names].each do |name|
              resources << Resource.find_or_initialize_by(name: name)
            end
            @role.resources = resources
            if @role.save
              present @role, with: V1::Entities::Role
            else
              {error_code: '10002', error_message: role.errors.messages}
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

        end



      end
    end
  end
end