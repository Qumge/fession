module V1
  module Admins
    class SignRules < Grape::API
      helpers V1::Admins::AdminLoginHelper
      include Grape::Kaminari
      before do
        authenticate!
        operator_auth!
      end

      resources 'sign_rules' do
        desc '签到规则', {
            headers: {
                "X-Auth-Token" => {
                    description: "登录token 运营平台账号",
                    required: false
                }
            }
        }
        get '/' do
          sign_rules = ::SignRule.order('number asc')
          present sign_rules, with: V1::Entities::SignRule
        end

        desc '创建变更签到规则', {
            headers: {
                "X-Auth-Token" => {
                    description: "登录token 运营平台账号",
                    required: false
                }
            }
        }
        params do
          requires :rules, type: String, desc: "签到规则[{number: 1, coin: 1}, {number: 5, coin: 10}]", default: [{number: 1, coin: 1}, {number: 5, coin: 10}].to_json
        end
        post '/' do
          sign_rules = ::SignRule.fetch_params params
          present sign_rules, with: V1::Entities::SignRule
        end
      end

    end
  end
end
