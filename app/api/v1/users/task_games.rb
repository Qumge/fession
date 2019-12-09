module V1
  module Users
    class TaskGames < Grape::API
      helpers V1::Users::UserLoginHelper
      include Grape::Kaminari
      # before do
      #   authenticate!
      # end

      resources 'task_games' do
        desc '游戏任务列表'
        params do
          optional :type, type: String, desc: '游戏类型 Game::Wheel Game::Egg Game::Scratch'
          optional :page,     type: Integer, default: 1, desc: '页码'
          optional :per_page, type: Integer, desc: '每页数据个数', default: Settings.per_page
          optional :status, type: String, desc: '任务状态', default: 'success'
        end
        get '/' do
          tasks = Task::GameTask.joins(:game).search_game_conn(params)
          present paginate(tasks), with: V1::Entities::Task
        end

        route_param :id do
          before do
            @task = ::Task::GameTask.find_by id: params[:id], status: 'success'
            error!("找不到数据", 500) unless @task.present?
          end
          desc '游戏任务详情'
          get '/' do
            present @task, with: V1::Entities::Task
          end
        end
      end
    end
  end
end