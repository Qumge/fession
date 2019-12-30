module V1
  module Admins
    class Orders < Grape::API
      helpers V1::Admins::AdminLoginHelper
      include Grape::Kaminari
      before do
        authenticate!
      end

      resources 'orders' do
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
          optional :no, type: String, desc: '订单编号'
          optional :type, type: String, desc: '订单类型 Order::CoinOrder Order::MoneyOrder'
          optional :company_id, type: Integer, desc: '商户id'
          optional :name, type: String, desc: '产品名'
          optional :game, type: Integer, desc: '游戏订单 1 正常订单 0'
          optional :status,     type: String, desc: "商品信息[{商品id ， 数量}] { wait: '待付款', pay: '待发货', send: '已发货', receive: '已完成', cancel: '已取消', after_sale: '售后订单'}"
        end
        get '/' do
          params[:company_id] =  @company.id if @company.present?
          orders = Order.search_conn(params)
          present paginate(orders), with: V1::Entities::Order
        end

        route_param :id do
          before do
            if @company.present?
              @order= Order.find_by id: params[:id], company: @company
            else
              @order= Order.find_by id: params[:id]
            end

            error!("找不到数据", 500) unless @order.present?
          end

          desc '订单详情', {
              headers: {
                  "X-Auth-Token" => {
                      description: "登录token",
                      required: false
                  }
              }
          }
          get '/' do
            present @order, with: V1::Entities::Order
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

          desc '发货 设置物流信息', {
              headers: {
                  "X-Auth-Token" => {
                      description: "登录token",
                      required: false
                  }
              }
          }
          params do
            requires :express_no, type: String, desc: '物流编号'
            optional :express_type, type: String, desc: '物流公司 可以不填'
          end
          patch 'express' do
            @order.update express_no: params[:express_no], express_type: params[:express_type]
            @order.do_send! if @order.may_do_send?
            present @order, with: V1::Entities::Order
          end

          desc '查询物流信息', {
              headers: {
                  "X-Auth-Token" => {
                      description: "登录token",
                      required: false
                  }
              }
          }
          get 'express' do
            @order.express
          end

          desc '发货 设置物流信息', {
              headers: {
                  "X-Auth-Token" => {
                      description: "登录token",
                      required: false
                  }
              }
          }
          params do
            requires :no, type: String, desc: '物流编号'
            requires :name, type: String, desc: '物流公司 yuantong zhongtong shunfeng'
          end
          post 'send' do
            @order.update express_no: params[:no], express_type: params[:name]
            @order.do_send! if @order.may_do_send?
            present @order, with: V1::Entities::Order
          end

          desc '同意、拒绝售后申请', {
              headers: {
                  "X-Auth-Token" => {
                      description: "登录token",
                      required: false
                  }
              }
          }
          params do
            requires :agree, type: Integer, desc: '1： 同意 0： 拒绝 '
          end
          post 'after_sale' do
            if params[:agree] == 1
              @order.do_after_sale! if @order.may_do_after_sale?
            else
              @order.do_after_failed! if @order.may_do_after_failed?
            end

            present @order, with: V1::Entities::Order
          end

        end
      end
    end
  end
end