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
          optional :status,     type: String, desc: "商品信息[{商品id ， 数量}] { wait: '代付款', pay: '代发货', send: '已发货', receive: '已完成', cancel: '已取消', after_sale: '售后订单'}"
        end
        get '/' do
          params[:company_id] =  @company.id if @company.present?
          orders = Order.search_conn(params)
          present paginate(orders), with: V1::Entities::Order
        end

        route_param :id do
          before do
             @order= Order.find_by id: params[:id], company: @company
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

          desc '发货', {
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
            logistic = Logistic.new order: @order
            logistic.update name: params[:name], no: params[:no]
            present @order, with: V1::Entities::Order
          end

        end
      end
    end
  end
end