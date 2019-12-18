module V1
  module Users
    class MyPosts < Grape::API
      helpers V1::Users::UserLoginHelper
      include Grape::Kaminari
      before do
        authenticate!
      end

      resources 'my_posts' do

        desc '我的帖子', {
            headers: {
                "X-Auth-Token" => {
                    description: "登录token",
                    required: false
                }
            }
        }
        params do
          optional :page,     type: Integer, default: 1, desc: '页码'
          optional :per_page, type: Integer, desc: '每页数据个数', default: Settings.per_page
        end
        get '/' do
          posts = @current_user.posts.show_sort
          present paginate(posts), with: V1::Entities::Post
        end

        desc '发帖', {
            headers: {
                "X-Auth-Token" => {
                    description: "登录token",
                    required: false
                }
            }
        }
        params do
          requires :title, type: String, desc: '标题'
          requires :content, type: String, desc: '内容'
          optional :images, type: String, desc: '图片 ["2.png", "4.png"]'
        end
        post '/' do
          post = @current_user.posts.new
          post =  post.fetch_params params
          if post.valid?
            present post, with: V1::Entities::Post
          else
            {error: '20001', message: post.errors.messages}
          end
        end


        route_param :id do
          before do
            @post =  @current_user.posts.find_by(id: params[:id])
            error!("找不到数据", 500) unless @post.present?
          end

          desc '编辑', {
              headers: {
                  "X-Auth-Token" => {
                      description: "登录token",
                      required: false
                  }
              }
          }
          params do
            requires :title, type: String, desc: '标题'
            requires :content, type: String, desc: '内容'
          end
          patch '/' do
            @post.fetch_params params
            if @post.valid?
              present @post, with: V1::Entities::Post
            else
              {error: '20001', message: @post.errors.messages}
            end
          end

          # desc '删除', {
          #     headers: {
          #         "X-Auth-Token" => {
          #             description: "登录token",
          #             required: false
          #         }
          #     }
          # }
          # params do
          #   requires 'type', type: String, desc: '类型Banner::PostBanner  Banner::TaskBanner'
          # end
          # delete '/' do
          #   if @banner.destroy
          #     {error: '', message: '删除成功'}
          #   else
          #     {error: '30001', message: '删除失败'}
          #   end
          # end


          desc '我的帖子详情', {
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
