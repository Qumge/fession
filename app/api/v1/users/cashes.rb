module V1
  module Users
    class Cashes < Grape::API
      helpers UserLoginHelper
      helpers QiniuHelper
      include Grape::Kaminari
      before do
        authenticate!
      end
      resources :cashes do
        desc '提现', {
            headers: {
                "X-Auth-Token" => {
                    description: "登录token",
                    required: false
                }
            }
        }
        params do
          requires :amount,     type: Integer,  desc: '金钱单位（元） 需要大于提现规则'
          requires :bank_code, type: String, desc: '收款方开户行	'
          requires :enc_bank_no, type: String, desc: '收款方银行卡号'
          requires :enc_true_name, type: String, desc: '收款方真实姓名'
        end
        post '/' do
          cash = @current_user.cashes.new
          cash = cash.fetch_params params
          if cash.errors.present?
            {error: '30001', message: cash.errors.messages}
          else
            present cash, with: V1::Entities::Cash
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
          optional :page,     type: Integer, default: 1, desc: '页码'
          optional :per_page, type: Integer, desc: '每页数据个数', default: Settings.per_page
        end
        get '/' do
          cashes = @current_user.cashes.order('created_at desc')
          present paginate(cashes), with: V1::Entities::Cash
        end


      end


    end
  end
end


