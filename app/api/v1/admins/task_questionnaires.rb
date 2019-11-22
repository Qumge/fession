module V1
  module Admins
    class TaskQuestionnaires < Grape::API
      helpers V1::Admins::AdminLoginHelper
      before do
        authenticate!
      end

      resources 'task_questionnaires' do
        before do
          @game_model = case params[:type]
                        when 'Game::Wheel'
                          Game::Wheel
                        when 'Game::Tiger'
                          Game::Tiger
                        when 'Game::Scratch'
                          Game::Scratch

                        end
          end
        desc '调查任务列表', {
            headers: {
                "X-Auth-Token" => {
                    description: "登录token",
                    required: false
                }
            }
        }
        get '/' do
          tasks = Task::QuestionnaireTask.where(company: @company)
          present tasks, with: V1::Entities::Task
        end

        desc '创建调查问卷任务', {
            headers: {
                "X-Auth-Token" => {
                    description: "登录token",
                    required: false
                }
            }
        }
        params do
          requires :name, type: String, desc: '标题'
          optional :desc, type: String, desc: '备注 描述'
          optional :questions, type: Array[Hash], desc: "问题 [{name: '玩过的游戏', type: 'Question::Multiple', options: ['dnf', 'dota', 'lol']}, {name: '性别', type: 'Question::Single', options: ['男', '女']}, {name: '建议', type: 'Question::Completion'}]", default: [{name: '玩过的游戏', type: 'Question::Multiple', options: ['dnf', 'dota', 'lol']}, {name: '性别', type: 'Option::Single', options: ['男', '女']}, {name: '建议', type: 'Question::Completion'}]
          requires :coin, type: Integer, desc: '金币总数'
          requires :valid_from, type: DateTime, desc: '有效期始'
          requires :valid_to, type: DateTime, desc: '有效至'
        end
        post '/' do
          questionnaire = ::Questionnaire.new name: params[:name], desc: params[:desc]
          questionnaire = questionnaire.fetch_questions params[:questions]
          task = Task::QuestionnaireTask.new  coin: params[:coin], valid_from: params[:valid_from], valid_to: params[:valid_to], company: @company, questionnaire: questionnaire

          if questionnaire.valid?
            if task.save
              present task, with: V1::Entities::Task
            else
              {error_code: '100001', error_message: task.errors}
            end
          else
            {error_code: '100001', error_message: questionnaire.errors}
          end
        end

        route_param :id do
          before do
            p Task::QuestionnaireTask.name
            @task = Task::QuestionnaireTask.find_by id: params[:id]
          end
          desc '问卷任务变更', {
              headers: {
                  "X-Auth-Token" => {
                      description: "登录token",
                      required: false
                  }
              }
          }
          params do
            requires :name, type: String, desc: '标题'
            optional :desc, type: String, desc: '备注 描述'
            optional :questions, type: Array[Hash], desc: "问题 [{name: '玩过的游戏', type: 'Question::Multiple', options: ['dnf', 'dota', 'lol']}, {name: '性别', type: 'Question::Single', options: ['男', '女']}, {name: '建议', type: 'Question::Completion'}]", default: [{name: '玩过的游戏', type: 'Question::Multiple', options: ['dnf', 'dota', 'lol']}, {name: '性别', type: 'Option::Single', options: ['男', '女']}, {name: '建议', type: 'Question::Completion'}]
            requires :coin, type: Integer, desc: '金币总数'
            requires :valid_from, type: DateTime, desc: '有效期始'
            requires :valid_to, type: DateTime, desc: '有效至'
          end
          patch '/' do
            questionnaire = @task.questionnaire
            questionnaire = questionnaire.fetch_questions params[:questions]
            if questionnaire.valid?
              if @task.update coin: params[:coin], valid_form: params[:valid_form], valid_to: params[:valid_to], company: @company
                present task, with: V1::Entities::Task
              else
                {code: '100001', error_message: @task.errors}
              end
            else
              {code: '100001', error_message: questionnaire.errors}
            end

          end

          desc '商品任务详情', {
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