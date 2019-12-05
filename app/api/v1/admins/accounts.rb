module V1
  module Admins
    class Accounts < Grape::API
      helpers AdminLoginHelper
      before do
        authenticate!
      end
      resources 'accounts' do
        desc '账户', {
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
          requires 'money', type: Integer, desc: '充值金额'
        end
        post 'charge' do
          if params[:company_id].present?
            @company ||= Company.find_by id: params[:company_id]
          end
          @company.update coin: @company.coin + 100 * params[:money]
          present @company, with: V1::Entities::Company
        end

      end
    end
  end

end