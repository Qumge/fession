module V1
  module Users
    class TaskArticles < Grape::API
      helpers V1::Users::UserLoginHelper
      include Grape::Kaminari
      # before do
      #   authenticate!
      # end

      resources 'task_articles' do
        desc '推文任务列表'
        params do
          optional :page,     type: Integer, default: 1, desc: '页码'
          optional :per_page, type: Integer, desc: '每页数据个数', default: Settings.per_page
          optional :status, type: String, desc: '任务状态', default: 'success'
        end
        get '/' do
          tasks = Task::ArticleTask.search_conn(params)
          present paginate(tasks), with: V1::Entities::Task
        end

        route_param :id do
          before do
            @task = ::Task::ArticleTask.find_by id: params[:id]
            error!("找不到数据", 500) unless @task.present?
          end

          desc '推文任务详情'
          get '/' do
            present @task, with: V1::Entities::Task
          end
        end
      end
    end
  end
end