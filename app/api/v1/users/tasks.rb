module V1
  module Users
    class Tasks < Grape::API
      # helpers V1::Users::UserLoginHelper
      include Grape::Kaminari

      resources 'tasks' do
        desc '所有任务'
        params do
          optional :page,     type: Integer, default: 1, desc: '页码'
          optional :per_page, type: Integer, desc: '每页数据个数', default: Settings.per_page
          optional :company_id, type: Integer, desc: '商户id'
          optional :name, type: String, desc: '检索'
        end
        get '/' do
          tasks = Task.user_search_conn(params)
          present paginate(tasks), with: V1::Entities::Task
        end

        desc '热门任务'
        params do
          optional :page,     type: Integer, default: 1, desc: '页码'
          optional :per_page, type: Integer, desc: '每页数据个数', default: Settings.per_page
        end
        get 'hot' do
          tasks = Task.valid_tasks.order('share_num desc')
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

        desc '热门广告'
        params do
          optional :page,     type: Integer, default: 1, desc: '页码'
          optional :per_page, type: Integer, desc: '每页数据个数', default: Settings.per_page
        end
        get 'hot_banners' do
          banners = Banner::HotBanner.order('no')
          present paginate(banners), with: V1::Entities::Banner
        end


        desc '店铺广告'
        params do
          requires :company_id, type: Integer, desc: '店铺id'
          optional :page,     type: Integer, default: 1, desc: '页码'
          optional :per_page, type: Integer, desc: '每页数据个数', default: Settings.per_page
        end
        get 'company_banners' do
          banners = Banner::CompanyBanner.where(company_id: params[:company_id]).order('no')
          present paginate(banners), with: V1::Entities::Banner
        end

        route_param :id do
          before do
            @task = ::Task.find_by id: params[:id]
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