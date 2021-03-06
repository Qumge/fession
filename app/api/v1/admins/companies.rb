module V1
  module Admins
    class Companies < Grape::API
      helpers V1::Admins::AdminLoginHelper
      include Grape::Kaminari
      resources 'companies' do

        before do
          authenticate!
          operator_auth!
        end


        desc '商户列表', {
            headers: {
                "X-Auth-Token" => {
                    description: "登录token",
                    required: false
                }
            }
        }
        params do
          optional 'status', type: String, desc: '商户状态 locked / active'
          optional 'search', type: String, desc: '商户名或编号检索'
          optional :page,     type: Integer, default: 1, desc: '页码'
          optional :per_page, type: Integer, desc: '每页数据个数', default: Settings.per_page
          optional :live, type: Integer, desc: '是否活跃 活跃： 1 不活跃： 0'
        end
        get '/' do
          companies = Company.search_conn(params).order('updated_at desc')
          present paginate(companies), with: V1::Entities::Company
        end


        desc '创建商户', {
            headers: {
                "X-Auth-Token" => {
                    description: "登录token",
                    required: false
                }
            }
        }
        params do
          requires 'name', type: String, desc: '商户名'
          requires 'login', type: String, desc: '商户账号'
          requires 'password', type: String, desc: '密码'
        end
        post '/' do
          company = Company.new name: params[:name]
          customer = Customer.new login: params[:login], company: company, role_type: 'admin_customer', password: params[:password]
          if customer.valid? && company.valid?
            customer.save
            present company, with: V1::Entities::Company
          else
            {error: '10001', message: customer.errors.messages.merge(company.errors.messages)&.values&.first&.first}
          end
        end

        desc '批量冻结  解冻', {
            headers: {
                "X-Auth-Token" => {
                    description: "登录token",
                    required: false
                }
            }
        }
        params do
          requires 'ids', type: String, desc: '商户id 数组 json '
          requires 'status', type: String, desc: '状态'
        end
        post 'change_status' do
          ids = JSON.parse params[:ids]
          companies = Company.where(id: ids)
          if ['active', 'locked'].include?(params[:status])
            if companies.update_all status: params[:status]
              present companies, with: V1::Entities::Company
            else
              {error: '20001', message: '变更失败'}
            end
          end
        end

        desc '批量删除 ', {
            headers: {
                "X-Auth-Token" => {
                    description: "登录token",
                    required: false
                }
            }
        }
        params do
          requires 'ids', type: String, desc: '商户id 数组 json '
        end
        post 'destroy' do
          ids = JSON.parse params[:ids]
          companies = Company.where(id: ids)
          if companies.destroy_all
            {error: '', message: '删除成功'}
          else
            {error: '30001', message: '删除失败'}
          end
        end



        route_param :id do
          before do
            @company = Company.find_by id: params[:id]
          end
          desc '商户变更', {
              headers: {
                  "X-Auth-Token" => {
                      description: "登录token",
                      required: false
                  }
              }
          }
          params do
            optional 'name', type: String, desc: '商户名'
            optional 'login', type: String, desc: '商户账号'
            optional 'status', type: String, desc: '状态 active locked'
            optional :password, type: String, desc: '密码'
          end
          patch '/' do
            @company.name = params[:name] if params[:name].present?
            customer = @company.customer
            customer.login = params[:login] if params[:login].present?
            customer.password = params[:password] if params[:password].present?
            @company.status = params[:status] if params[:status].present? && ['active', 'locked'].include?(params[:status])
            if customer.valid? && @company.valid?
              customer.save
              @company.save
              present @company, with: V1::Entities::Company
            else
              {error: '10001', message: customer.errors.messages.merge(@company.errors.messages)&.values&.first&.first}
            end
          end




          desc '商户详情', {
              headers: {
                  "X-Auth-Token" => {
                      description: "登录token",
                      required: false
                  }
              }
          }
          get '/' do
            present @company, with: V1::Entities::Company
          end

          desc '删除商户', {
              headers: {
                  "X-Auth-Token" => {
                      description: "登录token",
                      required: false
                  }
              }
          }
          delete '/' do
            if @company.total_amount > 0 || @company.invalid_amount > 0 || @company.coin > 0
              {error: '30001', message: '该商户有未使用金币或未提现金额'}
            else
              if @company.destroy
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
end