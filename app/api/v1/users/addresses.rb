module V1
  module Users
    class Addresses < Grape::API
      helpers V1::Users::UserLoginHelper
      include Grape::Kaminari
      before do
        authenticate!
      end

      resources 'addresses' do
        desc '我的地址', {
            headers: {
                "X-Auth-Token" => {
                    description: "登录token 运营平台账号",
                    required: false
                }
            }
        }
        get '/' do
          present @current_user.addresses, with: V1::Entities::Address
        end

        desc '创建地址', {
            headers: {
                "X-Auth-Token" => {
                    description: "登录token 运营平台账号",
                    required: false
                }
            }
        }
        params do
          requires :name, type: String, desc: '联系人'
          requires :phone, type: String, desc: '联系号码'
          requires :content, type: String, desc: '联系地址'
        end
        post '/' do
          address = @current_user.addresses.new name: params[:name], phone: params[:phone], content: params[:content]
          if address.save
            present address, with: V1::Entities::Address
          else
            {error: '20001', message: address.errors.messages}
          end
        end

        route_param :id do
          before do
            @address = @current_user.addresses.find_by id: params[:id]
            error!("找不到数据", 500) unless @address.present?
          end
          desc '地址详情', {
              headers: {
                  "X-Auth-Token" => {
                      description: "登录token 运营平台账号",
                      required: false
                  }
              }
          }
          get '/' do
            present @address, with: V1::Entities::Address
          end

          desc '变更地址', {
              headers: {
                  "X-Auth-Token" => {
                      description: "登录token 运营平台账号",
                      required: false
                  }
              }
          }
          params do
            requires :name, type: String, desc: '联系人'
            requires :phone, type: String, desc: '联系号码'
            requires :content, type: String, desc: '联系地址'
          end
          patch '/' do
            if @address.update name: params[:name], phone: params[:phone], content: params[:content]
              present @address, with: V1::Entities::Address
            else
              {error: '20001', message: @address.errors.messages}
            end
          end

          desc '删除地址', {
              headers: {
                  "X-Auth-Token" => {
                      description: "登录token 运营平台账号",
                      required: false
                  }
              }
          }
          delete '/' do
            if @address.destroy
              {error: '', message: '删除成功'}
            else
              {error: '20001', message: @address.errors.messages}
            end
          end

        end

      end

    end
  end
end
