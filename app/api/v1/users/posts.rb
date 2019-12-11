module V1
  module Users
    class Posts < Grape::API
      helpers V1::Users::UserLoginHelper
      include Grape::Kaminari

      resources 'posts' do
        desc '帖子'
        params do
          optional :user_id, type: Integer, desc: '用户id 用来查询该用户的帖子'
          optional :page,     type: Integer, default: 1, desc: '页码'
          optional :per_page, type: Integer, desc: '每页数据个数', default: Settings.per_page
        end

        get '/' do
          posts = Post.where(status: 'success').order('created_at desc')
          present paginate(posts), with: V1::Entities::Post, user: @current_user
        end

        route_param :id do
          before do
            @post = Post.find_by id: params[:id], status: 'success'
            error!("找不到数据", 500) unless @post.present?
          end


          desc '帖子详情', {
              headers: {
                  "X-Auth-Token" => {
                      description: "登录token 运营平台账号",
                      required: false
                  }
              }
          }
          get '/' do
            present @post, with: V1::Entities::Post, user: @current_user
          end

        end

      end


    end
  end
end
