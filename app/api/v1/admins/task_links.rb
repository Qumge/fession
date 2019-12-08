module V1
  module Admins
    class TaskLinks < Grape::API
      helpers V1::Admins::AdminLoginHelper
      include Grape::Kaminari
      before do
        authenticate!
      end

      resources 'task_links' do


        desc '外链任务列表', {
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
          optional :status, type: String, desc: "状态 wait: '待审核', failed: '已拒绝', success: '审核成功' 数据库中只存储这三种状态 进行中和已经结束（active overtime）由有效时间和success组合而成 检索时使用（wait active overtime failed ）"
        end
        get '/' do
          if params[:company_id].present?
            @company ||= Company.find_by id: params[:company_id]
          end
          tasks = Task::LinkTask.search_conn(params)
          if @company.present?
            tasks =  tasks.where(company: @company)
          end
          present paginate(tasks), with: V1::Entities::Task
        end

        desc '创建外链任务', {
            headers: {
                "X-Auth-Token" => {
                    description: "登录token",
                    required: false
                }
            }
        }
        params do
          requires :name, type: String, desc: '标题'
          requires :share_link, type: String, desc: '链接'
          requires :coin, type: Integer, desc: '金币总数'
          requires :valid_from, type: DateTime, desc: '有效期始'
          requires :valid_to, type: DateTime, desc: '有效至'
        end
        post '/' do
          task = Task::LinkTask.new coin: params[:coin], valid_from: params[:valid_from], valid_to: params[:valid_to], company: @company, name: params[:name], share_link: params[:share_link]
          if task.save
            present task, with: V1::Entities::Task
          end
        end

        route_param :id do
          before do
            if @company.present?
              @task = ::Task::LinkTask.find_by id: params[:id], company: @company
            else
              @task = ::Task::LinkTask.find_by id: params[:id]
            end
            error!("找不到数据", 500) unless @task.present?
          end

          desc '外链任务变更', {
              headers: {
                  "X-Auth-Token" => {
                      description: "登录token",
                      required: false
                  }
              }
          }
          params do
            requires :name, type: String, desc: '标题'
            requires :share_link, type: String, desc: '链接'
            requires :coin, type: Integer, desc: '金币总数'
            requires :valid_from, type: DateTime, desc: '有效期始'
            requires :valid_to, type: DateTime, desc: '有效至'
          end
          patch '/' do

          end

          desc '删除外链任务', {
              headers: {
                  "X-Auth-Token" => {
                      description: "登录token",
                      required: false
                  }
              }
          }
          delete '/' do
            if @task.failed? && @task.destroy
              {error_code: '20001', error_message: '删除失败'}
            else
              {error_code: '00000', error_message: '删除成功'}
            end
          end

          desc '外链任务详情', {
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