module V1
  module Users
    class Products < Grape::API
      helpers V1::Users::UserLoginHelper
      include Grape::Kaminari
      before do
        authenticate!
        @product_model = params[:type] == 'CoinProduct' ? CoinProduct : MoneyProduct
      end

      resources 'products' do
        desc '推文任务列表', {
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
          optional :type, type: String, desc: '类型', default: 'Money::Product'
        end
        get '/' do
          products = @product_model.where(status: 'up').search_conn(params)
          present paginate(products), with: V1::Entities::Product
        end

        route_param :id do
          before do
            @product = @product_model.find_by id: params[:id], status: 'up'
            error!("找不到数据", 500) unless @product.present?
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
            present @product, with: V1::Entities::Product
          end
        end
      end
    end
  end
end