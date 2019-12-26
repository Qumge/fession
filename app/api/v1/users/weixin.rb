module V1
  module Users
    class Weixin < Grape::API
      helpers V1::Users::UserLoginHelper

      resources 'weixin' do
        desc '微信jssdk'
        params do
          requires :url, type: String, desc: '当前页面url'
        end
        post 'jssdk' do
          s = ::Wechat.api.jsapi_ticket.signature params[:url]
          s
        end
      end
    end
  end
end