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
          optional 'task_id', type: Integer, desc: '任务id'
          optional :page, type: Integer, default: 1, desc: '页码'
          optional :per_page, type: Integer, desc: '每页数据个数', default: Settings.per_page
        end
        get '/' do
          logs = ::ShareLog.joins(fission_log: :task).order('share_logs.created_at desc')
          #logs = ::FissionLog.joins(:task, :share_logs).where('fission_logs.ancestry is null').order('fission_logs.created_at desc')
          if @company.present?
            params[:company_id] = @company.id
          end
          if params[:company_id].present?
            logs = logs.where("tasks.company_id =?", @company.id)
          end
          if params[:task_id].present?
            logs = logs.where('tasks.id = ?', params[:task_id])
          end
          present paginate(logs), with: V1::Entities::ShareLog
        end

        desc '任务分享详情日志', {
            headers: {
                "X-Auth-Token" => {
                    description: "登录token 运营平台账号",
                    required: false
                }
            }
        }
        params do
          requires :task_id, type: Integer, desc: '任务id'
        end
        get 'task' do
          task = Task.find_by id: params[:task_id]
          if task.present?
            present paginate(task.fission_logs.where(ancestry: nil)), with: V1::Entities::FissionLogTree
          else

          end
        end
      end
    end
  end
end
