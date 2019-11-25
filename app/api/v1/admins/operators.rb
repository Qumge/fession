module V1
  module Admins
    class Operators < Grape::API
      helpers V1::Admins::AdminLoginHelper
      include Grape::Kaminari
      resources 'operators' do

        before do
          authenticate!
          operator_auth!
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
          optional :page,     type: Integer, default: 1, desc: '页码'
          optional :per_page, type: Integer, desc: '每页数据个数', default: Settings.per_page
          optional :status, type: String, desc: "状态 传active/locked {active: '正常', locked: '已冻结'}"
          optional :role_id, type: Integer, desc: "角色 角色 角色列表从roles api 获取 per_page传最大值9999"
          optional :search, type: String, desc: '检索'
        end
        get '/' do
          operators = Operator.search_conn(params).where('id !=?', @current_admin.id).order('updated_at desc')
          present paginate(operators), with: V1::Entities::Admin
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
          operator = Operator.new role_type: 'normal'
          operator = operator.fetch_params params
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
            optional 'name', type: String, desc: '姓名'
            optional 'login', type: String, desc: '登录账号'
            optional 'role_id', type: Integer, desc: '角色'
            optional :status, type: String, desc: '状态  locked active'
          end
          patch '/' do
            @operator = @operator.fetch_params params
            if @operator.save
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

          desc '删除账号', {
              headers: {
                  "X-Auth-Token" => {
                      description: "登录token",
                      required: false
                  }
              }
          }
          delete '/' do
            if @operator.destroy
              {error_code: '00000', message: '删除成功'}
            else
              {error_code: '30001', message: '删除失败'}
            end
          end

        end



      end
    end
  end
end