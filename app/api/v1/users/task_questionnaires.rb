module V1
  module Users
    class TaskQuestionnaires < Grape::API
      helpers V1::Users::UserLoginHelper
      include Grape::Kaminari
      before do
        authenticate!
      end

      resources 'task_questionnaires' do
        desc '问卷任务列表'
        params do
          optional :page,     type: Integer, default: 1, desc: '页码'
          optional :per_page, type: Integer, desc: '每页数据个数', default: Settings.per_page
          optional :status, type: String, desc: '任务状态', default: 'success'
        end
        get '/' do
          tasks = Task::QuestionnaireTask.search_conn(params)
          present paginate(tasks), with: V1::Entities::Task
        end

        route_param :id do
          before do
            @task = ::Task::QuestionnaireTask.find_by id: params[:id]
            error!("找不到数据", 500) unless @task.present?
          end

          desc '问卷任务详情', {
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

          desc '问卷收集', {
              headers: {
                  "X-Auth-Token" => {
                      description: "登录token",
                      required: false
                  }
              }
          }
          params do
            requires :answer, type: String, desc: "收集答案{1: [1,2], }#{[{question_id: 1, option_id: [1], content: '不知道'}].to_json}"
          end
          post 'answer' do
            p @current_user, 333333333
            reply = Answer.fetch_params @current_user, @task.questionnaire, params
          end
        end
      end
    end
  end
end