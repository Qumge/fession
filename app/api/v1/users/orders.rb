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
          optional :address_id, type: Integer, desc: '地址'
          requires :product_norms,     type: String, desc: "商品信息[{商品id ， 数量}]#{[{id: 1, number: 2}, {id: 2, number: 2}, {id: 13, norm: {id: 13, number: 1}}, {id: 12, norm: {id: 11, number: 1}}].to_json}"
        end
        post '/' do
          orders = Order.apply_order @current_user, JSON.parse(params[:product_norms]), params[:address_id]
          present orders, with: V1::Entities::Order
        end


        desc '我的订单' , {
            headers: {
                "X-Auth-Token" => {
                    description: "登录token",
                    required: false
                }
            }
        }
        params do
          optional :type, type: String, desc: "Order::CoinOrder Order::MoneyOrder Order::GameOrder"
          optional :status, type: String, desc: "类型 { wait: '代付款', pay: '代发货', send: '待收货', receive: '已收货'}"
        end
        get 'my' do
          orders = @current_user.orders.search_user_conn(params)
          present paginate(orders), with: V1::Entities::Order
        end

        desc '订单批量查询 用于查看生成的订单  可能多个' , {
            headers: {
                "X-Auth-Token" => {
                    description: "登录token",
                    required: false
                }
            }
        }
        params do
          requires :ids, type: String, desc: "多个订单id , 隔开"
        end
        get 'apply' do
          orders = @current_user.orders.where(id: params[:ids].split(','))
          present orders, with: V1::Entities::Order
        end




        route_param :id do
          before do
             @order= @current_user.orders.find_by id: params[:id]
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

          desc '订单地址变更', {
              headers: {
                  "X-Auth-Token" => {
                      description: "登录token",
                      required: false
                  }
              }
          }
          params do
            optional :address_id, type: Integer, desc: '地址'
          end
          patch '/' do
            if params[:address_id].present?
              @order.update address_id: params[:address_id]
            end
            present @order, with: V1::Entities::Order
          end
        end
      end
    end
  end
end