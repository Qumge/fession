module V1
  module Users
    class Fissions < Grape::API
      helpers UserLoginHelper
      before do
        authenticate!
      end

      resources 'fissions' do
        desc '接任务 转发任务，生成用户的转发token', {
            headers: {
                "X-Auth-Token" => {
                    description: "登录token",
                    required: false
                }
            }
        }
        params do
          optional :token, type: String, desc: '上级转发'
          requires :task_id, type: Integer, desc: '验证码'
        end
        post '/' do
          fission_log = FissionLog.find_by user: @current_user, task_id: params[:task_id]
          unless fission_log.present?
            parent = FissionLog.find_by token: params[:token]
            fission_log = FissionLog.create user: @current_user, task_id: params[:task_id], token: SecureRandom.uuid, parent: parent
          end
          present fission_log, with: V1::Entities::FissionLog
        end
      end
    end
  end
end
