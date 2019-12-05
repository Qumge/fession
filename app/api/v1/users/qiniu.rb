module V1
  module Users
    class Qiniu < Grape::API
      helpers V1::Users::UserLoginHelper
      helpers V1::QiniuHelper
      before do
        authenticate!
      end
      resources 'qiniu' do
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