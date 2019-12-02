module V1
  module Admins
    class TaskProducts < Grape::API
      helpers V1::Admins::AdminLoginHelper
      include Grape::Kaminari
      before do
        authenticate!
      end
      resources 'task_products' do

        desc '商品任务列表', {
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
          optional :company_id, type: Integer, desc: '商户id'
          optional :status, type: String, desc: "状态 new: 新任务,  wait: '待审核', failed: '已拒绝', success: '审核成功' 数据库中只存储这四种状态 进行中和已经结束（active overtime）由有效时间和success组合而成 检索时使用（wait active overtime failed ）"
        end
        get '/' do
          if params[:company_id].present?
            @company ||= Company.find_by id: params[:company_id]
          end
          tasks = Task::ProductTask.search_conn(params).where(company: @company)
          present paginate(tasks), with: V1::Entities::Task
        end

        desc '创建商品任务', {
            headers: {
                "X-Auth-Token" => {
                    description: "登录token",
                    required: false
                }
            }
        }
        params do
          requires :product_id, type: Integer, desc: '产品id'
          requires :coin, type: Integer, desc: '金币总数'
          requires :valid_from, type: DateTime, desc: '有效期始'
          requires :valid_to, type: DateTime, desc: '有效至'
        end
        post '/' do
          task = Task::ProductTask.new model_id: params[:product_id], coin: params[:coin], valid_from: params[:valid_from], valid_to: params[:valid_to], company: @company
          if task.save
            present task, with: V1::Entities::Task
          end
        end

        route_param :id do
          before do
            @task = Task::ProductTask.find_by id: params[:id]
            error!("找不到数据", 500) unless @task.present?
          end

          desc '商品任务变更', {
              headers: {
                  "X-Auth-Token" => {
                      description: "登录token",
                      required: false
                  }
              }
          }
          params do
            requires :product_id, type: Integer, desc: '产品id'
            requires :coin, type: Integer, desc: '金币总数'
            requires :valid_from, type: DateTime, desc: '有效期始'
            requires :valid_to, type: DateTime, desc: '有效至'
          end
          patch '/' do
            if @task.update model_id: params[:product_id], coin: params[:coin], valid_from: params[:valid_from], valid_to: params[:valid_to], company: @company
              @task.do_recheck!
              present @task, with: V1::Entities::Task
            else
              {code: '100001', error_message: @task.errors}
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