module V1
  module Users
    class TaskGames < Grape::API
      helpers V1::Users::UserLoginHelper
      include Grape::Kaminari
      before do
        authenticate!
      end

      resources 'task_games' do
        desc '游戏任务列表', {
            headers: {
                "X-Auth-Token" => {
                    description: "登录token",
                    required: false
                }
            }
        }
        params do
          optional :page,     type: Integer, default: 1, desc: '页码'
          optional :per_page, type: Integer, desc: '每页数据个数', default: Settings.per_page
        end
        get '/' do
          tasks = Task::GameTask.where(status: 'success').search_conn(params)
          present paginate(tasks), with: V1::Entities::Task
        end

        route_param :id do
          before do
            @task = ::Task::GameTask.find_by id: params[:id], status: 'success'
            error!("找不到数据", 500) unless @task.present?
          end
          desc '游戏任务详情', {
              headers: {
                  "X-Auth-Token" => {
                      description: "登录token",
                      required: false
                  }
              }
          }
          get '/' do
            present @task, with: V1::Entities::Task
          end
        end
      end
    end
  end
end