module V1
  module Admins
    class ShareLogs < Grape::API
      helpers V1::Admins::AdminLoginHelper
      include Grape::Kaminari
      before do
        authenticate!
      end

      resources 'share_logs' do
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
          logs = ::ShareLog.left_joins(:fission_log)
          if @company.present?
            logs = logs.where("fission_los.company_id =?", @company.id)
          else
            if params[:company_id].present?
              logs = logs.where("fission_los.company_id =?", params[:company_id])
            end
          end
          present paginate(logs), with: V1::Entities::ShareLog
        end
      end
    end
  end
end
