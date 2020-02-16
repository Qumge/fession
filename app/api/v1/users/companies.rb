module V1
  module Users
    class Companies < Grape::API
      helpers UserLoginHelper
      helpers QiniuHelper
      include Grape::Kaminari
      before do
        authenticate!
      end
      resources :companies do
        route_param :id do
          before do
            @company = ::Company.find_by id: params[:id]
            error!("找不到数据", 500) unless @company.present?
          end
          desc '商户详情', {
            headers: {
                "X-Auth-Token" => {
                    description: "登录token",
                    required: false
                }
            }
          }
          get '/' do
            present @company, with: V1::Entities::Company, user: @current_user
          end

        end


      end


    end
  end
end


