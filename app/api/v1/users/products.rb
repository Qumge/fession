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
          optional :per_page, type: Integer, desc: '每页数据个数', default: 10
          optional :type, type: String, desc: '类型 MoneyProduct CoinProduct', default: 'MoneyProduct'
          optional :category_id, type: Integer, desc: '分类'
          optional :sort, type: String, desc: '排序'
          optional :search, type: String, desc: '检索'
          optional :company_id, type: Integer, desc: '商户id'
        end
        get '/' do
          products = @product_model.where(status: 'up').search_conn(params)
          present paginate(products), with: V1::Entities::Product
        end

        desc '根据ids查询商品规格信息'
        params do
          optional :page,     type: Integer, default: 1, desc: '页码'
          optional :per_page, type: Integer, desc: '每页数据个数', default: 10
          requires :ids, type: String, desc: '规格id数组'
        end
        get :norms do
          norms = ::Norm.where(id: JSON.parse(params[:ids]))
          present paginate(norms), with: V1::Entities::NormWithProduct
        end

        desc '根据id查询商品规格信息'
        params do
          requires :id, type: String, desc: '规格id数组'
        end
        get :norm do
          p params, 11111111
          norm = ::Norm.find_by(id: params[:id])
          present norm, with: V1::Entities::NormWithProduct
        end


        route_param :id do
          before do
            @product = @product_model.find_by id: params[:id], status: 'up'
            error!("找不到数据", 500) unless @product.present?
          end

          desc '商品详情'
          params do
            optional :type, type: String, desc: '类型MoneyProduct CoinProduct', default: 'MoneyProduct'
          end
          get '/' do
            @product.set_view
            present @product, with: V1::Entities::Product
          end
        end
      end
    end
  end
end