module V1
  module Admins
    class Audits < Grape::API
      helpers V1::Admins::AdminLoginHelper
      include Grape::Kaminari
      before do
        authenticate!
        operator_auth!
      end

      resources 'products' do
        desc '商品审核-状态变更', {
            headers: {
                "X-Auth-Token" => {
                    description: "登录token 运营平台账号",
                    required: false
                }
            }
        }
        params do
          requires 'ids', type: String, desc: '商品id [1,2]'
          requires 'status', type: String, desc: "要变更的状态 { wait: '审核中', success: '审核成功', down: '已下架', up: '已上架', failed: '审核失败'}"
          optional :reason, type: String, desc: '拒绝原因'
        end
        post :audit do
          if Product::STATUS[params[:status].to_sym].present?
            products = Product.where(id: JSON.parse(params[:ids]))
            begin
              Product.transaction do
                products.each do |product|
                  Audit::ProductAudit.create product: product, form_status: product.status, to_status: params[:status], admin: @current_admin, reason: params[:reason]
                  product.send "do_#{params[:status]}!" if product.send "may_do_#{params[:status]}?"
                end
              end
              present products, with: V1::Entities::Product
            rescue => e
              {error: '40001', message: "状态异常: #{e.message}"}
            end
          end
        end
      end


      resources 'tasks' do
        desc '任务审核-状态变更 运营平台账号', {
            headers: {
                "X-Auth-Token" => {
                    description: "登录token",
                    required: false
                }
            }
        }
        params do
          requires 'ids', type: String, desc: '商品id [1,2]'
          requires 'status', type: String, desc: "要变更的状态 { wait: '待审核', failed: '已拒绝', success: '审核成功'}"
          optional :reason, type: String, desc: '拒绝原因'
        end
        post :audit do
          if Task::STATUS[params[:status].to_sym].present?
            tasks = Task.where(id: JSON.parse(params[:ids]))
            tasks = tasks.where(company: @company) if @company.present?

            begin
              Task.transaction do
                tasks.each do |task|
                  Audit::TaskAudit.create task: task, form_status: task.status, to_status: params[:status], admin: @current_admin, reason: params[:reason]
                  task.send "do_#{params[:status]}!" if task.send "may_do_#{params[:status]}?"
                end
              end
              present tasks, with: V1::Entities::Task
            rescue => e
              {error: '40001', message: "状态异常: #{e.message}"}
            end

          end
        end
      end

      resources 'posts' do
        desc '帖子审核 运营平台账号', {
            headers: {
                "X-Auth-Token" => {
                    description: "登录token",
                    required: false
                }
            }
        }
        params do
          requires 'ids', type: String, desc: '帖子id [1,2]'
          requires 'status', type: String, desc: "要变更的状态 { wait: '待审核', failed: '已拒绝', success: '审核成功'}"
          optional :reason, type: String, desc: '拒绝原因'
        end
        post :audit do
          if Post::STATUS[params[:status].to_sym].present?
            posts = Post.where(id: JSON.parse(params[:ids]))
            begin
              Task.transaction do
                posts.each do |post|
                  Audit::PostAudit.create post: post, form_status: post.status, to_status: params[:status], admin: @current_admin, reason: params[:reason]
                  post.send "do_#{params[:status]}!" if post.send "may_do_#{params[:status]}?"
                end
              end
              present posts, with: V1::Entities::Post
            rescue => e
              {error: '40001', message: "状态异常: #{e.message}"}
            end

          end
        end
      end

      resources 'cash' do
        desc '提现审核 运营平台账号', {
            headers: {
                "X-Auth-Token" => {
                    description: "登录token",
                    required: false
                }
            }
        }
        params do
          requires 'ids', type: String, desc: '提现id [1,2]'
          requires 'status', type: String, desc: "要变更的状态 { wait: '待审核', failed: '已拒绝', success: '已同意', done: '已提现'}"
          optional :reason, type: String, desc: '拒绝原因'
        end
        post :audit do
          if ::Cash::STATUS[params[:status].to_sym].present?
            cashes = Cash.where(id: JSON.parse(params[:ids]))
            begin
              Task.transaction do
                cashes.each do |cash|
                  Audit::CashAudit.create cash: cash, form_status: cash.status, to_status: params[:status], admin: @current_admin, reason: params[:reason]
                  cash.send "do_#{params[:status]}!" if cash.send "may_do_#{params[:status]}?"
                end
              end
              present cashes, with: V1::Entities::Cash
            rescue => e
              {error: '40001', message: "状态异常: #{e.message}"}
            end

          end
        end
      end

    end
  end
end
