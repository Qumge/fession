module V1
  module Admins
    class Accounts < Grape::API
      helpers AdminLoginHelper
      include Grape::Kaminari
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
          requires 'amount', type: Integer, desc: '充值金额 整数 单位 元'
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
          optional :page,     type: Integer, default: 1, desc: '页码'
          optional :per_page, type: Integer, desc: '每页数据个数', default: Settings.per_page
        end
        post 'payments' do
          params[:company_id] = @company.id if @company.present?
          company_payments = CompanyPayment.where company_id: params[:company_id], status: 'pay'
          present paginate(company_payments), with: V1::Entities::CompanyPayment
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
          optional :page,     type: Integer, default: 1, desc: '页码'
          optional :per_page, type: Integer, desc: '每页数据个数', default: Settings.per_page
        end
        post 'coin_logs' do
          params[:company_id] = @company.id if @company.present?
          p params[:company_id], 11
          coin_logs = CoinLog.where company_id: params[:company_id]
          present paginate(coin_logs), with: V1::Entities::CoinLog
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

        desc '商户基本信息 total_amount： 总交易额 active_amount：  当前可用金额 withdraw_amount：  取钱金额 invalid_amount： 退单保护期金额： return_amount： 退单金额', {
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


        desc '提现', {
            headers: {
                "X-Auth-Token" => {
                    description: "登录token",
                    required: false
                }
            }
        }
        params do
          requires :amount, type: Integer, desc: '提现金额 整数 单位元'
        end
        post 'cash' do
          if @company.can_cash? params[:amount]
            cash = @company.do_cash params[:amount]
            present cash, with: V1::Entities::CompanyCash
          else
            {error: '40001', message: '账户金额不足或银行账户信息有误'}
          end
          
        end

        desc '提现记录', {
            headers: {
                "X-Auth-Token" => {
                    description: "登录token",
                    required: false
                }
            }
        }
        params do
          optional 'company_id', type: String, desc: '商户id 商户账号不用传'
          optional :page,     type: Integer, default: 1, desc: '页码'
          optional :per_page, type: Integer, desc: '每页数据个数', default: Settings.per_page
        end
        get 'cashes' do
          params[:company_id] = @company.id if @company.present?
          company_cashes = CompanyCash.where company_id: params[:company_id]
          present paginate(company_cashes), with: V1::Entities::CompanyCash
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
          optional :bank_code, type: String, desc: '银行编号{"1002"=>"工商银行", "1005"=>"农业银行", "1003"=>"建设银行", "1026"=>"中国银行", "1020"=>"交通银行", "1001"=>"招商银行", "1066"=>"邮储银行", "1006"=>"民生银行", "1010"=>"平安银行", "1021"=>"中信银行", "1004"=>"浦发银行", "1009"=>"兴业银行", "1022"=>"光大银行", "1027"=>"广发银行", "1025"=>"华夏银行", "1056"=>"宁波银行", "4836"=>"北京银行", "1024"=>"上海银行", "1054"=>"南京银行"}'
          optional :enc_bank_no, type: String, desc: '银行卡号'
          optional :enc_true_name, type: String, desc: '银行卡持有人姓名'
        end
        patch '/' do
          @company.name = params[:name] if params[:name].present?
          @company.image = Image.new file_path: params[:image], model_type: 'Company' if params[:image].present?
          @current_admin.login = params[:login] if params[:login].present?
          @current_admin.password = params[:password] if params[:password].present?
          @company.bank_code = params[:bank_code] if params[:bank_code].present?
          @company.enc_bank_no = params[:enc_bank_no] if params[:enc_bank_no].present?
          @company.enc_true_name = params[:enc_true_name] if params[:enc_true_name].present?
          if @current_admin.valid? && @company.valid?
            @current_admin.save
            @company.save
            present @company, with: V1::Entities::Company
          else
            {error: '10001', message: @current_admin.errors.messages&.values&.first&.first.merge(@company.errors.messages&.values&.first&.first)}
          end
        end

      end
    end
  end

end