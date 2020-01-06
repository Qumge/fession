module V1
  module Users
    class SignLogs < Grape::API
      helpers V1::Users::UserLoginHelper
      include Grape::Kaminari
      before do
        authenticate!
      end

      resources 'sign_logs' do
        desc '最后一次签到记录', {
            headers: {
                "X-Auth-Token" => {
                    description: "登录token",
                    required: false
                }
            }
        }
        params do
          optional :date_from, type: String, desc: '起始'
          optional :date_to, type: String, desc: '结束'
        end
        get '/' do
          present @current_user.sign_logs.search_conn(params), with: V1::Entities::SignLog
        end


        desc '签到', {
            headers: {
                "X-Auth-Token" => {
                    description: "登录token",
                    required: false
                }
            }
        }
        post '/' do
          present ::SignLog.sign(@current_user), with: V1::Entities::SignLog
        end


      end
    end
  end
end