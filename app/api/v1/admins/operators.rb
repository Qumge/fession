module V1
  module Admins
    class Operators < Grape::API
      helpers V1::Admins::AdminLoginHelper
      resources 'operators', message: '11' do

        before do
          authenticate!
        end


        desc '账号', {
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
          operators = Operator.order('updated_at desc').page(params[:page]).per(Settings.per_page)
          present operators, with: V1::Entities::Admin
        end


        desc '创建运营账号', {
            headers: {
                "X-Auth-Token" => {
                    description: "登录token",
                    required: false
                }
            }
        }
        params do
          requires 'name', type: String, desc: '姓名'
          requires 'login', type: String, desc: '登录账号'
          requires 'role_id', type: Integer, desc: '角色'
        end
        post '/' do
          role = Role.find_by id: params[:role_id]
          operator = Operator.new  role_type: 'normal', name: params[:name], login: params[:login], role: role
          if operator.save
            present operator, with: V1::Entities::Admin
          else
            {error_code: '00000', error_message: operator.errors.messages}
          end
        end


        route_param :id do
          before do
            @operator = Operator.find_by id: params[:id]
            error!("找不到数据", 500) unless @operator.present?
          end
          desc '运营账号变更', {
              headers: {
                  "X-Auth-Token" => {
                      description: "登录token",
                      required: false
                  }
              }
          }
          params do
            requires 'name', type: String, desc: '姓名'
            requires 'login', type: String, desc: '登录账号'
            requires 'role_id', type: Integer, desc: '角色'
          end
          patch '/' do
            role = Role.find_by id: params[:role_id]
            if @operator.update name: params[:name], login: params[:login], role: role
              present @operator, with: V1::Entities::Admin
            else
              {error_code: '00000', error_message: @operator.errors.messages}
            end
          end


          desc '账号详情', {
              headers: {
                  "X-Auth-Token" => {
                      description: "登录token",
                      required: false
                  }
              }
          }
          get '/' do
            present @operator, with: V1::Entities::Admin
          end

        end



      end
    end
  end
end