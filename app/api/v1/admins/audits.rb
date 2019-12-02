module V1
  module Admins
    class Audits < Grape::API
      helpers V1::Admins::AdminLoginHelper
      include Grape::Kaminari
      before do
        authenticate!
        #operator_auth!
      end

      resources 'products' do
        desc '商品审核-状态变更', {
            headers: {
                "X-Auth-Token" => {
                    description: "登录token",
                    required: false
                }
            }
        }
        params do
          requires 'ids', type: String, desc: '商品id [1,2]'
          requires 'status', type: String, desc: '要变更的状态'
        end
        post :audit do
          if @current_admin.type == 'Customer' && params[:status] != 'wait'
            error!("错误的权限", 500)
          else
            if Product::STATUS[params[:status].to_sym].present?
              p 1111
              products = Product.where(id: JSON.parse(params[:ids]))
              products = products.where(compang: @company)if @company.present?
              begin
                Product.transaction do
                  products.each do |product|
                    product.send "do_#{params[:status]}!"
                  end
                end
                present products, with: V1::Entities::Product
              rescue => e
                {error_code: '40001', error_message: "状态异常: #{e.message}"}
              end
            end
          end
        end
      end


      resources 'tasks' do
        desc '商品审核-状态变更', {
            headers: {
                "X-Auth-Token" => {
                    description: "登录token",
                    required: false
                }
            }
        }
        params do
          requires 'ids', type: String, desc: '商品id [1,2]'
          requires 'status', type: String, desc: '要变更的状态'
        end
        post :audit do
          if @current_admin.type == 'Customer' && params[:status] != 'wait'
            error!("错误的权限", 500)
          else
            if Task::STATUS[params[:status].to_sym].present?
              tasks = Task.where( id: JSON.parse(params[:ids]))
              tasks = tasks.where(company: @company)if @company.present?
              begin
                Task.transaction do
                  tasks.each do |task|
                    task.send "do_#{params[:status]}!"
                  end
                end
                present tasks, with: V1::Entities::Task
              rescue => e
                {error_code: '40001', error_message: "状态异常: #{e.message}"}
              end

            end
          end
        end
      end

    end
  end
end
