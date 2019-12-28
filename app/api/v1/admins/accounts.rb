module V1
  module Admins
    class Accounts < Grape::API
      helpers AdminLoginHelper
      before do
        authenticate!
      end
      resources 'accounts' do
        desc '充值', {
            headers: {
                "X-Auth-Token" => {
                    description: "登录token",
                    required: false
                }
            }
        }
        params do
          # company_id 'status', type: String, desc: '商户状态 locked / active'
          optional 'company_id', type: String, desc: '商户id'
          requires 'amount', type: Integer, desc: '充值金额'
        end
        post 'charge' do
          @company ||= Company.find_by id: params[:company_id]
          if @company.present?
            company_payment = CompanyPayment.create company: @company, amount: params[:amount] * 100
            present company_payment, with: V1::Entities::CompanyPayment
          else
            {error: '400001', message: '找不到商户'}
          end
        end


        desc '充值记录', {
            headers: {
                "X-Auth-Token" => {
                    description: "登录token",
                    required: false
                }
            }
        }
        params do
          # company_id 'status', type: String, desc: '商户状态 locked / active'
          optional 'company_id', type: String, desc: '商户id 商户账号不用传'
        end
        post 'payments' do
          params[:company_id] = @company.id if @company.present?
          company_payments = CompanyPayment.where company_id: params[:company_id]
          present company_payments, with: V1::Entities::CompanyPayment
        end

        desc '消费记录', {
            headers: {
                "X-Auth-Token" => {
                    description: "登录token",
                    required: false
                }
            }
        }
        params do
          # company_id 'status', type: String, desc: '商户状态 locked / active'
          optional 'company_id', type: String, desc: '商户id 商户账号不用传'
        end
        post 'coin_logs' do
          params[:company_id] = @company.id if @company.present?
          p params[:company_id], 11
          coin_logs = CoinLog.where company_id: params[:company_id]
          present coin_logs, with: V1::Entities::CoinLog
        end

        desc '校验是否充值成功 status: pay标识充值成功', {
            headers: {
                "X-Auth-Token" => {
                    description: "登录token",
                    required: false
                }
            }
        }
        params do
          # company_id 'status', type: String, desc: '商户状态 locked / active'
          optional 'company_id', type: String, desc: '商户id'
          requires :id, type: Integer, desc: '充值记录id'
        end
        post 'check_charge' do
          @company ||= Company.find_by id: params[:company_id]
          if @company.present?
            company_payment = CompanyPayment.find_by company: @company, id: params[:id]
            present company_payment, with: V1::Entities::CompanyPayment
          else
            {error: '400001', message: '找不到商户'}
          end
        end

        before do
          error!('错误的商户账号', 500) unless @company.present?
        end

        desc '商户基本信息', {
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


        desc '商户基本信息设置', {
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
          #optional 'status', type: String, desc: '状态 active locked'
          optional 'image', type: String, desc: '图片'
          optional 'password', type: String, desc: '密码'
        end
        patch '/' do
          @company.name = params[:name] if params[:name].present?
          @company.image = Image.new file_path: params[:image], model_type: 'Company' if params[:image].present?
          @current_admin.login = params[:login] if params[:login].present?
          @current_admin.password = params[:password] if params[:password].present?
          if @current_admin.valid? && @company.valid?
            @current_admin.save
            @company.save
            present @company, with: V1::Entities::Company
          else
            {error: '10001', message: @current_admin.errors.messages.merge(@company.errors.messages)}
          end
        end

      end
    end
  end

end