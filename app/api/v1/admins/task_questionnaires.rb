module V1
  module Admins
    class TaskQuestionnaires < Grape::API
      helpers V1::Admins::AdminLoginHelper
      include Grape::Kaminari
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
        params do
          optional 'sorts', type: String, desc: "排序[{column: 'coin', sort: 'desc'}, {column: 'number', sort: 'desc'}]", default: [{column: 'coin', sort: 'desc'}, {column: 'number', sort: 'desc'}].to_json
          optional :page,     type: Integer, default: 1, desc: '页码'
          optional :per_page, type: Integer, desc: '每页数据个数', default: Settings.per_page
          optional :company_id, type: Integer, desc: '商户id'
          optional :status, type: String, desc: "状态 wait: '待审核', failed: '已拒绝', success: '审核成功' 数据库中只存储这三种状态 进行中和已经结束（active overtime）由有效时间和success组合而成 检索时使用（wait active overtime failed ）"
          optional :search, type: String, desc: '名称检索'
        end
        get '/' do
          if params[:company_id].present?
            @company ||= Company.find_by id: params[:company_id]
          end
          tasks = Task::QuestionnaireTask.joins(:questionnaire).search_conn(params)
          if @company.present?
            tasks =  tasks.where(company: @company)
          end
          if params[:search].present?
            tasks = tasks.where('questionnaires.name like ?', "%#{params[:search]}%")
          end
          present paginate(tasks), with: V1::Entities::Task
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
          optional :questions, type: String, desc: "问题 [{name: '玩过的游戏', type: 'Question::Multiple', options: ['dnf', 'dota', 'lol']}, {name: '性别', type: 'Question::Single', options: ['男', '女']}, {name: '建议', type: 'Question::Completion'}]", default: [{name: '玩过的游戏', type: 'Question::Multiple', options: ['dnf', 'dota', 'lol']}, {name: '性别', type: 'Question::Single', options: ['男', '女']}, {name: '建议', type: 'Question::Completion'}].to_json
          requires :coin, type: Integer, desc: '金币总数'
          requires :valid_from, type: DateTime, desc: '有效期始'
          requires :valid_to, type: DateTime, desc: '有效至'
          requires :image, type: String, desc: '展示图'
        end
        post '/' do
          image = Image.new file_path: params[:image], model_type: 'Task'
          questionnaire = ::Questionnaire.new name: params[:name], desc: params[:desc]
          questionnaire.company = @company
          questionnaire = questionnaire.fetch_questions JSON.parse(params[:questions])
          task = Task::QuestionnaireTask.new  coin: params[:coin], valid_from: params[:valid_from], valid_to: params[:valid_to], company: @company, questionnaire: questionnaire, image: image

          if questionnaire.valid?
            if task.save
              present task, with: V1::Entities::Task
            else
              {error: '100001', message: task.errors}
            end
          else
            {error: '100001', message: questionnaire.errors}
          end
        end

        route_param :id do
          before do
            #@task = Task::QuestionnaireTask.find_by id: params[:id], company: @company
            if @company.present?
              @task = Task::QuestionnaireTask.find_by id: params[:id], company: @company
            else
              @task = Task::QuestionnaireTask.find_by id: params[:id]
            end
            error!("找不到数据", 500) unless @task.present?
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
            optional :questions, type: String, desc: "问题 [{name: '玩过的游戏', type: 'Question::Multiple', options: ['dnf', 'dota', 'lol']}, {name: '性别', type: 'Question::Single', options: ['男', '女']}, {name: '建议', type: 'Question::Completion'}]", default: [{name: '玩过的游戏', type: 'Question::Multiple', options: ['dnf', 'dota', 'lol']}, {name: '性别', type: 'Question::Single', options: ['男', '女']}, {name: '建议', type: 'Question::Completion'}].to_json
            requires :coin, type: Integer, desc: '金币总数'
            requires :valid_from, type: DateTime, desc: '有效期始'
            requires :valid_to, type: DateTime, desc: '有效至'
            requires :image, type: String, desc: '展示图'
          end
          patch '/' do
            image = Image.new file_path: params[:image], model_type: 'Task'
            questionnaire = @task.questionnaire
            questionnaire = questionnaire.fetch_questions JSON.parse(params[:questions]) if params[:questions].present?
            if questionnaire.valid?
              if @task.update coin: params[:coin], valid_from: params[:valid_form], valid_to: params[:valid_to], company: @company, image: image
                @task.do_wait! if @task.may_do_wait?
                present @task, with: V1::Entities::Task
              else
                {code: '100001', message: @task.errors}
              end
            else
              {code: '100001', message: questionnaire.errors}
            end

          end

          desc '删除调查问卷任务', {
              headers: {
                  "X-Auth-Token" => {
                      description: "登录token",
                      required: false
                  }
              }
          }
          delete '/' do
            if @task.failed? && @task.destroy
              {error: '', message: '删除成功'}
            else
              {error: '20001', message: '删除失败'}
            end
          end

          desc '调查问卷任务详情', {
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