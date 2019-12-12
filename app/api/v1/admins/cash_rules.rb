module V1
  module Admins
    class CashRules < Grape::API
      helpers V1::Admins::AdminLoginHelper
      include Grape::Kaminari
      before do
        authenticate!
        operator_auth!
      end

      resources 'cash_rules' do
        desc '提现规则', {
            headers: {
                "X-Auth-Token" => {
                    description: "登录token 运营平台账号",
                    required: false
                }
            }
        }
        get '/' do
          cash_rule = ::CashRule.first
          present cash_rule, with: V1::Entities::CashRule
        end

        desc '创建、变更提现规则', {
            headers: {
                "X-Auth-Token" => {
                    description: "登录token 运营平台账号",
                    required: false
                }
            }
        }
        params do
          requires :coin, type: Integer, desc: '规则1元钱金币数量'
          requires :floor, type: Integer, desc: '金币兑换门槛 单位rmb： 10rmb； 默认兑换最小单位 1rmb'
        end
        post '/' do
          cash_rule = ::CashRule.first
          cash_rule = CashRule.new unless cash_rule.present?
          cash_rule.update coin: params[:coin], floor: params[:floor]
          present cash_rule, with: V1::Entities::CashRule
        end
      end

    end
  end
end
