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
          optional :status,     type: String, desc: "商品信息[{商品id ， 数量}] { wait: '代付款', pay: '代发货', send: '待收货', receive: '已收货'}"
        end
        get '/' do
          orders = Order.where(company: @company).order('created_at  desc')
          present paginate(orders), with: V1::Entities::Order
        end

        route_param :id do
          before do
             @order= Order.find_by id: params[:id], compoany: @company
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
        end
      end
    end
  end
end