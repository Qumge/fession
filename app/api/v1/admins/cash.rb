module V1
  module Admins
    class Cash < Grape::API
      helpers V1::Admins::AdminLoginHelper
      include Grape::Kaminari
      before do
        authenticate!
        operator_auth!
      end

      resources 'cash' do
        desc '分享日志', {
            headers: {
                "X-Auth-Token" => {
                    description: "登录token 运营平台账号",
                    required: false
                }
            }
        }
        params do
          optional 'status', type: String, desc: "状态 { wait: '待审核', failed: '已拒绝', success: '已同意', done: '已提现'}"
          optional :page, type: Integer, default: 1, desc: '页码'
          optional :per_page, type: Integer, desc: '每页数据个数', default: Settings.per_page
        end
        get '/' do
          cashes = ::Cash.order('created_at desc')
          present paginate(cashes), with: V1::Entities::Cash
        end
      end
    end
  end
end
