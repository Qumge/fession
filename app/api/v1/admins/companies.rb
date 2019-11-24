module V1
  module Admins
    class Companies < Grape::API
      helpers V1::Admins::AdminLoginHelper
      include Grape::Kaminari
      paginate per_page:  Settings.per_page, max_per_page: 30, offset: 0
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
          optional 'page', type: String, desc: '页码', default: 1
          optional 'status', type: String, desc: '商户状态 locked / active'
          optional 'search', type: String, desc: '商户名或编号检索'
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
        end
        post '/' do
          company = Company.new name: params[:name]
          customer = Customer.new login: params[:login], company: company, role_type: 'admin_customer'
          if customer.valid? && company.valid?
            customer.save
            present company, with: V1::Entities::Company
          else
            {error_code: '10001', error_message: customer.errors.messages.merge(company.errors.messages)}
          end
        end


        desc '商户状态变更', {
            headers: {
                "X-Auth-Token" => {
                    description: "登录token",
                    required: false
                }
            }
        }
        params do
          requires :ids, type: Array[Integer], desc: '商户id数组'
          requires :status, type: String, desc: '状态'
        end
        post 'change_status' do
          companies = Company.where(id: params[:ids])
          if params[:status] == 'active'
            companies.update_all status: 'active', active_at: DateTime.now
          elsif params[:status] == 'locked'
            companies.update_all status: 'locked', locked_at: DateTime.now
          end
          present companies, with: V1::Entities::Company
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
            requires 'name', type: String, desc: '商户名'
            requires 'login', type: String, desc: '商户账号'
          end
          patch '/' do

            @company.name = params[:name]
            customer = @company.customer
            customer.login = params[:login]
            if customer.valid? && @company.valid?
              customer.save
              @company.save
              present @company, with: V1::Entities::Company
            else
              {error_code: '10001', error_message: customer.errors.messages.merge(@company.errors.messages)}
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

        end


      end
    end
  end
end