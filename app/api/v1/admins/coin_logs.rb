module V1
  module Admins
    class CoinLogs < Grape::API
      helpers V1::Admins::AdminLoginHelper
      include Grape::Kaminari
      before do
        authenticate!
      end

      resources 'coin_logs' do
        desc '分享日志', {
            headers: {
                "X-Auth-Token" => {
                    description: "登录token 运营平台账号",
                    required: false
                }
            }
        }
        params do
          optional 'company_id', type: String, desc: '商户id'
          optional :page, type: Integer, default: 1, desc: '页码'
          optional :per_page, type: Integer, desc: '每页数据个数', default: Settings.per_page
        end
        get '/' do
          logs = ::CoinLog.order('created_at desc')
          present paginate(logs), with: V1::Entities::CoinLog
        end
      end
    end
  end
end
