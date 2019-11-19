module V1
  module Admins
    class Companies < Grape::API
      helpers V1::Admins::AdminLoginHelper
      resources 'companies' do

        before do
          authenticate!
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
        end
        get '/' do
          companies = Company.order('updated_at desc').page(params[:page]).per(Settings.per_page)
          present companies, with: V1::Entities::Company
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
            {error_code: '00000', error_message: customer.errors.messages.merge(company.errors.messages)}
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

          desc '商户冻结', {
              headers: {
                  "X-Auth-Token" => {
                      description: "登录token",
                      required: false
                  }
              }
          }
          get 'lock' do
            @company.do_lock!
            present @company, with: V1::Entities::Company
          end

        end



      end
    end
  end
end