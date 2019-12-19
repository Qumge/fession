module V1
  module Users
    class Orders < Grape::API
      helpers V1::Users::UserLoginHelper
      include Grape::Kaminari
      before do
        authenticate!
      end

      resources 'orders' do
        desc '下单' , {
            headers: {
                "X-Auth-Token" => {
                    description: "登录token",
                    required: false
                }
            }
        }
        params do
          requires :product_norms,     type: String, desc: "商品信息[{商品id ， 数量}]#{[{id: 1, number: 2}, {id: 2, number: 2}, {id: 13, norm: {id: 13, number: 1}}, {id: 12, norm: {id: 11, number: 1}}].to_json}"
        end
        post '/' do
          orders = Order.apply_order @current_user, JSON.parse(params[:product_norms])
          present orders, with: V1::Entities::Order
        end

        route_param :id do
          before do
             @order= @current_user.orders.find_by id: params[:id], status: 'up'
            error!("找不到数据", 500) unless @order.present?
          end

          desc '推文任务详情', {
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