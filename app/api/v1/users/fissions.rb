module V1
  module Users
    class Fissions < Grape::API
      helpers UserLoginHelper
      before do
        authenticate!
      end

      resources 'fissions' do
        desc '接任务生成用户的转发token', {
            headers: {
                "X-Auth-Token" => {
                    description: "登录token",
                    required: false
                }
            }
        }
        params do
          optional :token, type: String, desc: '上级转发token'
          requires :task_id, type: Integer, desc: '任务id'
        end
        post '/' do
          fission_log = FissionLog.find_by user: @current_user, task_id: params[:task_id]
          unless fission_log.present?
            parent = FissionLog.find_by token: params[:token]
            fission_log = FissionLog.create user: @current_user, task_id: params[:task_id], token: SecureRandom.uuid, parent: parent
          end
          present fission_log, with: V1::Entities::FissionLog
        end


        desc '转发事件回调', {
            headers: {
                "X-Auth-Token" => {
                    description: "登录token",
                    required: false
                }
            }
        }
        params do
          requires :token, type: String, desc: '本次任务的token'
        end
        post 'share' do
          fission_log = FissionLog.find_by user: @current_user, token: params[:token]
          if fission_log.present?
            share_log = ShareLog.create user: current_user, fission_log: fission_log
            present share_log, with: V1::Entities::ShareLog
          else
            {error_code: '50001', error_message: '错误的分享吗'}
          end
        end
      end
    end
  end
end
