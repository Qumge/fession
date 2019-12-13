module V1
  module Admins
    class Posts < Grape::API
      helpers V1::Admins::AdminLoginHelper
      include Grape::Kaminari
      before do
        authenticate!
        operator_auth!
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
          optional :search, type: String, desc: '帖子标题'
          optional :status, type: String, desc: '帖子状态 wait success failed'
          optional :page, type: Integer, default: 1, desc: '页码'
          optional :per_page, type: Integer, desc: '每页数据个数', default: Settings.per_page
        end
        get '/' do
          posts = Post.order('created_at desc')
          present paginate(posts), with: V1::Entities::Post
        end





        route_param :id do
          before do
            @post = Post.find_by id: params[:id]
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
            present @post, with: V1::Entities::Post
          end
        end
      end


    end
  end
end
