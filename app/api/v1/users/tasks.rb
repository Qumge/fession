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

        desc '任务banner'
        get 'task_banner'

      end
    end
  end
end