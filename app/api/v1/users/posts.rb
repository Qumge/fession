module V1
  module Users
    class Posts < Grape::API
      helpers V1::Users::UserLoginHelper
      include Grape::Kaminari
      before do
        authenticate!
      end

      resources 'posts' do
        desc '帖子', {
            headers: {
                "X-Auth-Token" => {
                    description: "登录token 运营平台账号",
                    required: false
                }
            }
        }
        params do
          optional :user_id, type: Integer, desc: '用户id 用来查询该用户的帖子'
          optional :page,     type: Integer, default: 1, desc: '页码'
          optional :per_page, type: Integer, desc: '每页数据个数', default: Settings.per_page
          optional :follow_user, type: Integer, desc: '为1时表示 我关注的人的帖子'
        end
        get '/' do
          posts = Post.where(status: 'success').order('created_at desc')
          if params[:follow_user].present? && params[:follow_user].to_i == 1
            posts = posts.where(user: @current_user.follow_users)
          end

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
