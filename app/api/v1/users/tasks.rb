module V1
  module Users
    class Tasks < Grape::API
      helpers V1::Users::UserLoginHelper
      include Grape::Kaminari

      resources 'tasks' do
        desc '热门任务'
        params do
          optional :page,     type: Integer, default: 1, desc: '页码'
          optional :per_page, type: Integer, desc: '每页数据个数', default: Settings.per_page
        end
        get 'hot' do
          tasks = Task.order('share_num desc')
          present paginate(tasks), with: V1::Entities::Task
        end

        desc '任务广告'
        params do
          optional :page,     type: Integer, default: 1, desc: '页码'
          optional :per_page, type: Integer, desc: '每页数据个数', default: Settings.per_page
        end
        get 'task_banners' do
          banners = Banner::TaskBanner.order('no')
          present paginate(banners), with: V1::Entities::Banner
        end

        desc '帖子广告'
        params do
          optional :page,     type: Integer, default: 1, desc: '页码'
          optional :per_page, type: Integer, desc: '每页数据个数', default: Settings.per_page
        end
        get 'post_banners' do
          banners = Banner::PostBanner.order('no')
          present paginate(banners), with: V1::Entities::Banner
        end

        route_param :id do
          before do
            @task = ::Task.find_by id: params[:id], status: 'success'
            error!("找不到数据", 500) unless @task.present?
          end
          desc '任务详情'
          get '/' do
            present @task, with: V1::Entities::Task
          end
        end

      end
    end
  end
end