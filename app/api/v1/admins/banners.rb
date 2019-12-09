module V1
  module Admins
    class Banners < Grape::API
      helpers V1::Admins::AdminLoginHelper
      include Grape::Kaminari
      before do
        authenticate!
        operator_auth!
        @banner_model = params[:type] == 'Banner::PostBanner' ? Banner::PostBanner : Banner::TaskBanner
      end

      resources 'banners' do
        desc 'banner广告', {
            headers: {
                "X-Auth-Token" => {
                    description: "登录token 运营平台账号",
                    required: false
                }
            }
        }
        params do
          requires 'type', type: String, desc: '类型 Banner::PostBanner  Banner::TaskBanner'
          optional :page,     type: Integer, default: 1, desc: '页码'
          optional :per_page, type: Integer, desc: '每页数据个数', default: Settings.per_page
        end
        get '/' do
          banners = @banner_model.order('no')
          present paginate(banners), with: V1::Entities::Banner
        end

        desc '创建banner广告', {
            headers: {
                "X-Auth-Token" => {
                    description: "登录token 运营平台账号",
                    required: false
                }
            }
        }
        params do
          requires 'type', type: String, desc: '类型Banner::PostBanner  Banner::TaskBanner'
          requires :image, type: String, desc: '图片路径'
          requires :task_id, type: Integer, desc: '任务id'
        end
        post '/' do
          banner = @banner_model.new
          banner =  banner.fetch_params params
          if banner.valid?
            present banner, with: V1::Entities::Banner
          else
            {error: '20001', message: banner.errors.messages}
          end
        end


        route_param :id do
          before do
            @banner = @banner_model.find_by id: params[:id]
            error!("找不到数据", 500) unless @banner.present?
          end

          desc '编辑', {
              headers: {
                  "X-Auth-Token" => {
                      description: "登录token 运营平台账号",
                      required: false
                  }
              }
          }
          params do
            requires 'type', type: String, desc: '类型Banner::PostBanner  Banner::TaskBanner'
            requires :image, type: String, desc: '图片路径'
            requires :task_id, type: Integer, desc: '任务id'
          end
          patch '/' do
            banner =  @banner.fetch_params params
            if banner.valid?
              present banner, with: V1::Entities::Banner
            else
              {error: '20001', message: banner.errors.messages}
            end
          end

          desc '删除', {
              headers: {
                  "X-Auth-Token" => {
                      description: "登录token 运营平台账号",
                      required: false
                  }
              }
          }
          params do
            requires 'type', type: String, desc: '类型Banner::PostBanner  Banner::TaskBanner'
          end
          delete '/' do
            if @banner.destroy
              {error: '', message: '删除成功'}
            else
              {error: '30001', message: '删除失败'}
            end
          end

          desc '上移、下移', {
              headers: {
                  "X-Auth-Token" => {
                      description: "登录token 运营平台账号",
                      required: false
                  }
              }
          }
          params do
            requires 'type', type: String, desc: '类型Banner::PostBanner  Banner::TaskBanner'
            requires 'action', type: String, desc: '动作： up down'
          end
          post 'sort' do
            if params[:action] == 'down'
              @banner.down
            elsif params[:action] == 'up'
              @banner.up
            end
            present @banner, with: V1::Entities::Banner
          end

          desc 'banner详情', {
              headers: {
                  "X-Auth-Token" => {
                      description: "登录token 运营平台账号",
                      required: false
                  }
              }
          }
          params do
            requires 'type', type: String, desc: '类型Banner::PostBanner  Banner::TaskBanner'
          end
          get '/' do
            present @banner, with: V1::Entities::Banner
          end

        end

      end


    end
  end
end
