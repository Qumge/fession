module V1
  module Users
    class Products < Grape::API
      helpers V1::Users::UserLoginHelper
      include Grape::Kaminari
      before do
        @product_model = params[:type] == 'CoinProduct' ? CoinProduct : MoneyProduct
      end

      resources 'products' do
        desc '商品列表'
        params do
          optional :page,     type: Integer, default: 1, desc: '页码'
          optional :per_page, type: Integer, desc: '每页数据个数', default: 6
          optional :type, type: String, desc: '类型 MoneyProduct CoinProduct', default: 'MoneyProduct'
          optional :category_id, type: Integer, desc: '分类'
          optional :sort, type: String, desc: '排序'
          optional :search, type: String, desc: '检索'
          optional :ids, type: String, desc: '批量查询用于购物车数据商品查询'
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

          desc '推文任务详情'
          params do
            optional :type, type: String, desc: '类型MoneyProduct CoinProduct', default: 'MoneyProduct'
          end
          get '/' do
            present @product, with: V1::Entities::Product
          end
        end
      end
    end
  end
end