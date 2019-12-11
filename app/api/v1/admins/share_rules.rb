module V1
  module Admins
    class ShareRules < Grape::API
      helpers V1::Admins::AdminLoginHelper
      include Grape::Kaminari
      before do
        authenticate!
        operator_auth!
      end

      resources 'share_rules' do
        desc '奖励规则', {
            headers: {
                "X-Auth-Token" => {
                    description: "登录token 运营平台账号",
                    required: false
                }
            }
        }
        get '/' do
          share_rules = ShareRule.order('level')
          present paginate(share_rules), with: V1::Entities::ShareRule
        end

        desc '创建、变更奖励规则', {
            headers: {
                "X-Auth-Token" => {
                    description: "登录token 运营平台账号",
                    required: false
                }
            }
        }
        params do
          requires :rules, type: String, desc: '规则[{"level": 1, coin: 10}, {"level": 2, coin: 5}]', default: [{level: 1, coin: 10}, {level: 2, coin: 5}, {level: 3, coin: 3}, {level: 4, coin: 1}].to_json
        end
        post '/' do
          share_rules = ::ShareRule.fetch_params JSON.parse(params[:rules])
          present paginate(share_rules), with: V1::Entities::ShareRule
        end
      end

    end
  end
end
