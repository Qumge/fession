module V1
  module Admins
    class AfterOrders < Grape::API
      helpers V1::Admins::AdminLoginHelper
      include Grape::Kaminari
      before do
        authenticate!
      end

      resources 'after_orders' do
        desc '订单列表' , {
            headers: {
                "X-Auth-Token" => {
                    description: "登录token",
                    required: false
                }
            }
        }
        params do
          optional :date_from, type: String, desc: '起始时间'
          optional :date_to, type: String, desc: '截止时间'
          optional :order_type, type: String, desc: '订单类型 Order::CoinOrder Order::MoneyOrder'
          optional :company_id, type: Integer, desc: '商户id'
          optional :type, type: String, desc: '类型 AfterOrder::All : 退货退款 AfterOrder::Money ： 退款'
          optional :name, type: String, desc: '产品名'
          optional :status,     type: String, desc: "{ apply: '申请', agree: '已同意', failed: '已拒绝', receive: '已退货待退款', refund: '已退款'}"
        end
        get '/' do
          params[:company_id] =  @company.id if @company.present?
          after_orders = AfterOrder.search_conn params
          present paginate(after_orders), with: V1::Entities::AfterOrderWithOrder
        end

        route_param :id do
          before do
            if @company.present?
              @after_order = AfterOrder.find_by id: params[:id], company: @company
            else
              @after_order= AfterOrder.find_by id: params[:id]
            end
            p @after_order, 1111

            error!("找不到数据", 500) unless @after_order.present?
          end

          desc '售后订单详情', {
              headers: {
                  "X-Auth-Token" => {
                      description: "登录token",
                      required: false
                  }
              }
          }
          get '/' do
            present @after_order, with: V1::Entities::AfterOrderWithOrder
          end

          #
          # desc '发货 设置物流信息', {
          #     headers: {
          #         "X-Auth-Token" => {
          #             description: "登录token",
          #             required: false
          #         }
          #     }
          # }
          # params do
          #   requires :express_no, type: String, desc: '物流编号'
          #   optional :express_type, type: String, desc: '物流公司 可以不填'
          # end
          # patch 'express' do
          #   @order.update express_no: params[:express_no], express_type: params[:type]
          #   @order.do_send! if @order.may_do_send?
          #   present @order, with: V1::Entities::Order
          # end

          desc '查询物流信息', {
              headers: {
                  "X-Auth-Token" => {
                      description: "登录token",
                      required: false
                  }
              }
          }
          get 'express' do
            @after_order.express
          end


          desc '售后订单状态变更 同意 拒绝 收货  退款', {
              headers: {
                  "X-Auth-Token" => {
                      description: "登录token",
                      required: false
                  }
              }
          }
          params do
            requires :status, type: String, desc: "状态变更 agree: '已同意', failed: '已拒绝', receive: '收到退货', refund: '退款'"
          end
          post 'after_sale' do
            @after_order.send "do_#{params[:status]}!" if @after_order.send "may_do_#{params[:status]}?"
            present @after_order, with: V1::Entities::AfterOrderWithOrder
          end

        end
      end
    end
  end
end