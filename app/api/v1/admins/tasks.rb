module V1
  module Admins
    class Tasks < Grape::API
      helpers AdminLoginHelper
      include Grape::Kaminari
      before do
        authenticate!
      end
      resources 'tasks' do
        desc '所有任务', {
            headers: {
                "X-Auth-Token" => {
                    description: "登录token",
                    required: false
                }
            }
        }
        params do
          # company_id 'status', type: String, desc: '商户状态 locked / active'
          optional 'company_id', type: Integer, desc: '商户id'
          optional 'type', type: String, desc: '类型 Task::GameTask Task::ProductTask Task::LinkTask Task::ArticleTask Task::QuestionnaireTask' 
          optional :page,     type: Integer, default: 1, desc: '页码'
          optional :per_page, type: Integer, desc: '每页数据个数', default: Settings.per_page
        end
        get 'tasks' do
          tasks = Task.joins(:company).all.order('tasks.created_at desc')
          if params[:company_id].present?
            tasks = tasks.where(company_id: params[:company_id])
          end
          if params[:type].present?
            tasks = tasks.where(type: params[:type])
          end
          present paginate(tasks), with: V1::Entities::Task
        end

        desc '任务分享记录树状图', {
            headers: {
                "X-Auth-Token" => {
                    description: "登录token",
                    required: false
                }
            }
        }
        params do
          # company_id 'status', type: String, desc: '商户状态 locked / active'
          optional 'task_id', type: Integer, desc: '任务id'
          optional :page,     type: Integer, default: 1, desc: '页码'
          optional :per_page, type: Integer, desc: '每页数据个数', default: Settings.per_page
        end
        get 'fission_logs' do
          fission_logs = FissionLog.roots
          if params[:task_id].present?
            fission_logs = fission_logs.where(task_id: params[:task_id])
          end
          present paginate(fission_logs), with: V1::Entities::FissionLogTree
        end        

      end
    end
  end

end