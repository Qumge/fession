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
        desc '提现记录', {
            headers: {
                "X-Auth-Token" => {
                    description: "登录token 运营平台账号",
                    required: false
                }
            }
        }
        params do
          optional 'status', type: String, desc: "状态 { wait: '待审核', failed: '已拒绝', success: '已同意'}"
          optional 'pay_status', type: String, desc: "状态 { wait: '审核中', failed: '打款失败', success: '打款成功', paying: '打款中'}"
          optional :page, type: Integer, default: 1, desc: '页码'
          optional :per_page, type: Integer, desc: '每页数据个数', default: Settings.per_page
        end
        get '/' do
          cashes = ::Cash.order('created_at desc')
          if params[:status].present?
            cashes.where(status: params[:status])
          end
          if params[:pay_status].present?
            cashes.where(pay_status: params[:pay_status])
          end
          present paginate(cashes), with: V1::Entities::Cash
        end
      end
    end
  end
end
