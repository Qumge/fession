module V1
  module Admins
    class Products < Grape::API
      helpers V1::Admins::AdminLoginHelper
      include Grape::Kaminari
      resources 'products' do

        before do
          authenticate!
          @product_model = params[:type] == 'CoinProduct' ? CoinProduct : MoneyProduct
          if params[:type] == 'CoinProduct'
            operator_auth!
          end
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
          optional 'type', type: String, desc: '类型MoneyProduct CoinProduct', default: 'MoneyProduct'
          optional 'sorts', type: String, desc: "排序[{column: 'price', sort: 'desc'}, {column: 'sale', sort: 'desc'}, {column: 'stock', sort: 'desc'}]", default: [{column: 'price', sort: 'desc'}, {column: 'sale', sort: 'desc'}, {column: 'stock', sort: 'desc'}].to_json
          optional 'search', type: String, desc: '名称检索'
          optional 'company_id', type: String, desc: '商户id'
          optional 'status', type: String, desc: "状态  { wait: '审核中', success: '审核成功', down: '已下架', up: '已上架', failed: '审核失败'}"
          optional :page,     type: Integer, default: 1, desc: '页码'
          optional :per_page, type: Integer, desc: '每页数据个数', default: Settings.per_page
        end
        get '/' do
          if @company.present?
            params[:company_id] = @company.id
          end
          products = @product_model.search_conn(params)
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
          optional 'coin', type: Integer, desc: '返金币'
          requires 'price', type: Integer, desc: '价格'
          requires 'type', type: String, desc: '类型 CoinProduct MoneyProduct', default: 'MoneyProduct'
          requires 'images', type: String, desc: '图片路径["www.baidu.com/aa.png", "www.baidu.com/aa.png"]'
          optional 'stock', type: Integer, desc: '库存'
          optional 'specs', type: String, desc: "规格 [{name: '颜色', values: ['红色', '黑色']}, {name: '尺码', values: ['xl', 'xxl']}]", default:  [{name: '颜色', values: ['红色', '黑色']}, {name: '尺码', values: ['xl', 'xxl']}].to_json
          optional 'norms', type: String, desc: "规格详细 [{name: ['红色', 'xl'], price: 1000, stock: 1000}, {name: ['黑色', 'xl'], price: 1000, stock: 1000}, {name: ['红色', 'xxl'], price: 1000, stock: 1000}, {name: ['黑色', 'xxl'], price: 1000, stock: 1000}]", default: [{name: ['红色', 'xl'], price: 1000, stock: 1000}, {name: ['黑色', 'xl'], price: 1000, stock: 1000}, {name: ['红色', 'xxl'], price: 1000, stock: 1000}, {name: ['黑色', 'xxl'], price: 1000, stock: 1000}].to_json
          optional 'desc', type: String, desc: '备注'
        end
        post '/' do
          product = @product_model.new.fetch_for_api params, @company
          if product.valid?
            present product.reload, with: V1::Entities::Product
          else
            {error: '10002', message: product.errors.messages&.values&.first&.first}
          end
        end


        desc '批量删除商品', {
            headers: {
                "X-Auth-Token" => {
                    description: "登录token",
                    required: false
                }
            }
        }
        params do
          requires :ids, type: String, desc: '需要删除的商品数组'
        end
        post 'destroy' do
          products = @product_model.where(id: JSON.parse(params[:ids]), company: @company)
          if products.destroy_all
            {error: '',  message: '删除成功'}
          else
            {error: '30001',  message: '删除失败'}
          end
        end


        desc '上下架商品', {
            headers: {
                "X-Auth-Token" => {
                    description: "登录token",
                    required: false
                }
            }
        }
        params do
          requires 'ids', type: String, desc: '[1,2]'
          requires 'status', type: String, desc: '状态 上架：up 下架： down'
        end
        post :change_status do
          products = @product_model.where(id: JSON.parse(params[:ids]), company: @company)
          products.each do |product|
            product.send("do_#{params[:status]}!") if product.send("may_do_#{params[:status]}?")
          end
          present products, with: V1::Entities::Product
        end


        route_param :id do
          before do
            p 11111
            if @company.present?
              @product = Product.find_by id: params[:id], company: @company
            else
              @product = Product.find_by id: params[:id]
            end
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
            optional 'category_id', type: Integer, desc: '分类'
            optional 'coin', type: Integer, desc: '返金币'
            optional 'images', type: String, desc: '图片路径["www.baidu.com/aa.png", "www.baidu.com/aa.png"]'
            optional 'stock', type: Integer, desc: '库存'
            optional 'specs', type: String, desc: "规格", default:  [{name: '颜色', values: ['红色', '黑色']}, {name: '尺码', values: ['xl', 'xxl']}].to_json
            optional 'norms', type: String, desc: "规格详细", default: [{name: ['红色', 'xl'], price: 1000, stock: 1000}, {name: ['黑色', 'xl'], price: 1000, stock: 1000}, {name: ['红色', 'xxl'], price: 1000, stock: 1000}, {name: ['黑色', 'xxl'], price: 1000, stock: 1000}].to_json
            optional 'type', type: String, desc: '类型 CoinProduct MoneyProduct', default: 'MoneyProduct'
            optional 'price', type: Integer, desc: '价格 type是CoinProduct的时候必填'
            optional 'desc', type: String, desc: '备注'
            #optional 'status', type: String, desc: "商户上架传'check' 需要先审核 {wait: '新商品', check: '审核中', down: '已下架', up: '已上架', failed: '审核失败'}"
          end
          patch '/' do
            product = @product.fetch_for_api params
            if product.valid?
              present product, with: V1::Entities::Product
            else
              {error: '10002', message: product.errors.messages&.values&.first&.first}
            end
          end

          desc '申请审核', {
              headers: {
                  "X-Auth-Token" => {
                      description: "登录token",
                      required: false
                  }
              }
          }
          post 'apply' do
            @product.do_wait! if @product.may_do_wait?
            present @product, with: V1::Entities::Product
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

          desc '删除商品', {
              headers: {
                  "X-Auth-Token" => {
                      description: "登录token",
                      required: false
                  }
              }
          }
          delete '/' do
            if @product.destroy
              {error: '',  message: '删除成功'}
            else
              {error: '30001',  message: '删除失败'}
            end
          end
        end
      end
    end
  end
end