module V1
  module Admins
    class Audits < Grape::API
      helpers V1::Admins::AdminLoginHelper
      include Grape::Kaminari
      before do
        authenticate!
        #operator_auth!
      end
      resources 'products' do
        route_param :id do
          before do
            @category = Category.find_by id: params[:id]
            error!("找不到数据", 500) unless @category.present?
          end
          desc '分类变更', {
              headers: {
                  "X-Auth-Token" => {
                      description: "登录token",
                      required: false
                  }
              }
          }
          params do
            requires 'id', type: String, desc: '商品id'
            optional 'status', type: Integer, desc: '要变更的状态'
          end
          get :audit do

          end
        end
      end

      resources 'products' do
        route_param :id do
          before do
            @category = Category.find_by id: params[:id]
            error!("找不到数据", 500) unless @category.present?
          end
          desc '分类变更', {
              headers: {
                  "X-Auth-Token" => {
                      description: "登录token",
                      required: false
                  }
              }
          }
          params do
            requires 'id', type: String, desc: '商品id'
            requires 'status', type: Integer, desc: '要变更的状态'
          end
          get :audit do
            if Product::STATUS[params[:status.to_sym]].present?
              self.send "do_#{params[:status]}!"
            end
          end
        end

      end
    end
  end
end
