module V1
  module Admins
    class Products < Grape::API
      helpers V1::Admins::AdminLoginHelper
      include Grape::Kaminari
      resources 'products' do

        before do
          authenticate!
          @product_model = params[:type] == 'CoinProduct' ? CoinProduct : MoneyProduct
        end


        desc '商品列表', {
            headers: {
                "X-Auth-Token" => {
                    description: "登录token",
                    required: false
                }
            }
        }
        params do
          optional 'type', type: String, desc: '类型', default: 'MoneyProduct CoinProduct'
          optional 'search', type: String, desc: '名称检索'
          optional 'company_id', type: String, desc: '商户id'
          optional :page,     type: Integer, default: 1, desc: '页码'
          optional :per_page, type: Integer, desc: '每页数据个数', default: Settings.per_page
        end
        get '/' do
          products = @product_model.search_conn(params).order('updated_at desc')
          present paginate(products), with: V1::Entities::Product
        end


        desc '创建商品', {
            headers: {
                "X-Auth-Token" => {
                    description: "登录token",
                    required: false
                }
            }
        }
        params do
          requires 'name', type: String, desc: '商品名'
          requires 'category_id', type: Integer, desc: '分类'
          requires 'coin', type: Integer, desc: '返金币'
          requires 'images', type: Array[String], desc: '图片路径["www.baidu.com/aa.png", "www.baidu.com/aa.png"]'
          optional 'stock', type: Integer, desc: '库存'
          optional 'specs', type: Array[Hash], desc: "规格 [{name: '颜色', values: ['红色', '黑色']}, {name: '尺码', values: ['xl', 'xxl']}]", default:  [{name: '颜色', values: ['红色', '黑色']}, {name: '尺码', values: ['xl', 'xxl']}]
          optional 'norms', type: Array[Hash], desc: "规格详细 [{name: ['红色', 'xl'], price: 1000, stock: 1000}, {name: ['黑色', 'xl'], price: 1000, stock: 1000}, {name: ['红色', 'xxl'], price: 1000, stock: 1000}, {name: ['黑色', 'xxl'], price: 1000, stock: 1000}]", default: [{name: ['红色', 'xl'], price: 1000, stock: 1000}, {name: ['黑色', 'xl'], price: 1000, stock: 1000}, {name: ['红色', 'xxl'], price: 1000, stock: 1000}, {name: ['黑色', 'xxl'], price: 1000, stock: 1000}]
          optional 'type', type: String, desc: '类型 CoinProduct MoneyProduct', default: 'MoneyProduct'
          optional 'price', type: Integer, desc: '价格 type是CoinProduct的时候必填'
          optional 'desc', type: String, desc: '备注'
        end
        post '/' do
          product = @product_model.new.fetch_for_api params, @company
          if product.valid?
            present product, with: V1::Entities::Product
          else
            {error_code: '10002', error_message: product.errors.messages}
          end
        end


        route_param :id do
          before do
            @product = Product.find_by id: params[:id], company: @company
            error!("找不到数据", 500) unless @product.present?
          end

          desc '商品变更', {
              headers: {
                  "X-Auth-Token" => {
                      description: "登录token",
                      required: false
                  }
              }
          }
          params do
            requires 'name', type: String, desc: '商品名'
            requires 'category_id', type: Integer, desc: '分类'
            optional 'coin', type: Integer, desc: '返金币'
            optional 'images', type: Array[String], desc: '图片路径["www.baidu.com/aa.png", "www.baidu.com/aa.png"]'
            optional 'stock', type: Integer, desc: '库存'
            optional 'norms', type: Array[Hash], desc: "规格详细 [{name: ['红色', 'xl'], price: 1000, stock: 1000}, {name: ['黑色', 'xl'], price: 1000, stock: 1000}, {name: ['红色', 'xxl'], price: 1000, stock: 1000}, {name: ['黑色', 'xxl'], price: 1000, stock: 1000}]", default: [{name: ['红色', 'xl'], price: 1000, stock: 1000}, {name: ['黑色', 'xl'], price: 1000, stock: 1000}, {name: ['红色', 'xxl'], price: 1000, stock: 1000}, {name: ['黑色', 'xxl'], price: 1000, stock: 1000}]
            optional 'specs', type: Array[Hash], desc: "规格", default:  [{name: '颜色', values: ['红色', '黑色']}, {name: '尺码', values: ['xl', 'xxl']}]
            optional 'norms', type: Array[Hash], desc: "规格详细", default: [{name: ['红色', 'xl'], price: 1000, stock: 1000}, {name: ['黑色', 'xl'], price: 1000, stock: 1000}, {name: ['红色', 'xxl'], price: 1000, stock: 1000}, {name: ['黑色', 'xxl'], price: 1000, stock: 1000}]
            optional 'type', type: String, desc: '类型 CoinProduct MoneyProduct', default: 'MoneyProduct'
            optional 'price', type: Integer, desc: '价格 type是CoinProduct的时候必填'
            optional 'desc', type: String, desc: '备注'
          end
          patch '/' do
            product = @product.fetch_for_api params
            if product.valid?
              present product, with: V1::Entities::Product
            else
              {error_code: '10002', error_message: product.errors.messages}
            end
          end


          desc '商品详情', {
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