module V1
  module Admins
    class Products < Grape::API
      helpers V1::Admins::AdminLoginHelper
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
          optional 'page', type: String, desc: '页码', default: 1
          optional 'type', type: String, desc: '页码', default: 'MoneyProduct'
        end
        get '/' do
          products = @product_model.order('updated_at desc').page(params[:page]).per(Settings.per_page)
          present products, with: V1::Entities::Product
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
          requires 'images', type: Array[String], desc: '图片路径["www.baidu.com/aa.png", "www.baidu.com/aa.png"]'
          requires 'stock', type: Integer, desc: '库存'
          #optional 'norms', type: Array[Hash] , desc: '规格你个: [{name: '', stock: '', price: ''}, {name: '', stock: '', price: ''}] 传递的价格统一以分为单位', default: []
          optional :norms, type: Array[Hash], desc: "规格: 这里测试时候不要填(bug)，默认数据:[{id: null, name: '规格1', price: 1000, stock: 100}]", default: [{name: '规格1', price: 1000, stock: 100}]
          optional 'type', type: String, desc: '类型 CoinProduct MoneyProduct', default: 'MoneyProduct'
          optional 'price', type: Integer, desc: '价格 type是CoinProduct的时候必填'
          optional 'desc', type: String, desc: '备注'
        end
        post '/' do
          product = Product.new_for_api params, @company
          if product.save
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
            requires 'stock', type: Integer, desc: '库存'
            #optional 'norms', type: Array[Hash] , desc: '规格你个: [{name: '', stock: '', price: ''}, {name: '', stock: '', price: ''}] 传递的价格统一以分为单位', default: []
            optional 'norms', type: Array[Hash], desc: "规格: 这里测试时候不要填(bug)，默认数据:[{id: null, name: '规格1', price: 1000, stock: 100}]", default: [{name: '规格1', price: 1000, stock: 100}]
            optional 'type', type: String, desc: '类型 CoinProduct MoneyProduct', default: 'MoneyProduct'
            optional 'price', type: Integer, desc: '价格 type是CoinProduct的时候必填'
            optional 'desc', type: String, desc: '备注'
          end
          patch '/' do
            product = @product.edit_for_api params
            if product.save
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