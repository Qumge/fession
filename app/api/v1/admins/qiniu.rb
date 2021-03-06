module V1
  module Admins
    class Qiniu < Grape::API
      helpers V1::Admins::AdminLoginHelper
      helpers V1::QiniuHelper
      before do
        authenticate!
      end
      resources 'qiniu' do
        before do
          authenticate!
        end
        desc '七牛token', {
            headers: {
                "X-Auth-Token" => {
                    description: "登录token",
                    required: false
                }
            }
        }
        get 'token' do
          {qiniu_token: uptoken}
        end
      end
    end
  end
end