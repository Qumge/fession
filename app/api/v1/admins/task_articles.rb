module V1
  module Admins
    class TaskArticles < Grape::API
      helpers V1::Admins::AdminLoginHelper
      include Grape::Kaminari
      before do
        authenticate!
      end

      resources 'task_articles' do


        desc '推文任务列表', {
            headers: {
                "X-Auth-Token" => {
                    description: "登录token",
                    required: false
                }
            }
        }
        params do
          optional 'sorts', type: String, desc: "排序[{column: 'coin', sort: 'desc'}, {column: 'number', sort: 'desc'}]", default: [{column: 'coin', sort: 'desc'}, {column: 'number', sort: 'desc'}].to_json
          optional :page,     type: Integer, default: 1, desc: '页码'
          optional :per_page, type: Integer, desc: '每页数据个数', default: Settings.per_page
          optional :company_id, type: Integer, desc: '商户id'
          optional :status, type: String, desc: "状态 wait: '待审核', failed: '已拒绝', success: '审核成功' 数据库中只存储这三种状态 进行中和已经结束（active overtime）由有效时间和success组合而成 检索时使用（wait active overtime failed ）"
          optional :search, type: String, desc: '名称检索'
        end
        get '/' do
          if params[:company_id].present?
            @company ||= Company.find_by id: params[:company_id]
          end
          tasks = Task::ArticleTask.joins(:article).search_conn(params)
          if @company.present?
            tasks =  tasks.where(company: @company)
          end
          if params[:search].present?
            tasks = tasks.where('articles.subject like ?', "%#{params[:search]}%")
          end
          present paginate(tasks), with: V1::Entities::Task
        end

        desc '创建推文任务', {
            headers: {
                "X-Auth-Token" => {
                    description: "登录token",
                    required: false
                }
            }
        }
        params do
          requires :product_id, type: Integer, desc: '关联商品id'
          requires :subject, type: String, desc: '标题'
          requires :content, type: String, desc: '内容'
          requires :coin, type: Integer, desc: '金币总数'
          requires :valid_from, type: DateTime, desc: '有效期始'
          requires :valid_to, type: DateTime, desc: '有效至'
          requires :image, type: String, desc: '展示图'
          requires :commission, type: Integer, desc: '阅读文章赚佣金'
        end
        post '/' do
          image = Image.new file_path: params[:image], model_type: 'Task'
          article = ::Article.new product_id: params[:product_id], company: @company, subject: params[:subject], content: params[:content]
          task = Task::ArticleTask.new article: article, coin: params[:coin], valid_from: params[:valid_from], valid_to: params[:valid_to], company: @company, image: image, commission: params[:commission]
          if task.save
            present task, with: V1::Entities::Task
          end
        end

        route_param :id do
          before do
            if @company.present?
              @task = ::Task::ArticleTask.find_by id: params[:id], company: @company
            else
              @task = ::Task::ArticleTask.find_by id: params[:id]
            end
            error!("找不到数据", 500) unless @task.present?
          end

          desc '推文任务变更', {
              headers: {
                  "X-Auth-Token" => {
                      description: "登录token",
                      required: false
                  }
              }
          }
          params do
            requires :product_id, type: Integer, desc: '产品id'
            requires :coin, type: Integer, desc: '金币总数'
            requires :valid_from, type: DateTime, desc: '有效期始'
            requires :valid_to, type: DateTime, desc: '有效至'
            requires :image, type: String, desc: '展示图'
            requires :commission, type: Integer, desc: '阅读文章赚佣金'
          end
          patch '/' do
            image = Image.new file_path: params[:image], model_type: 'Task'
            article = @task.article
            article.attributes = {product_id: params[:product_id], company: @company, subject: params[:subject], content: params[:content]}
            if @task.update article: article, coin: params[:coin], valid_from: params[:valid_from], valid_to: params[:valid_to], company: @company, image: image, commission: params[:commission]
              @task.do_wait! if @task.may_do_wait?
              present @task, with: V1::Entities::Task
            else
              {code: '100001', message: @task.errors}
            end
          end

          desc '删除推文任务', {
              headers: {
                  "X-Auth-Token" => {
                      description: "登录token",
                      required: false
                  }
              }
          }
          delete '/' do
            if @task.failed? && @task.destroy
              {error: '', message: '删除成功'}
            else
              {error: '20001', message: '删除失败'}
            end
          end

          desc '推文任务详情', {
              headers: {
                  "X-Auth-Token" => {
                      description: "登录token",
                      required: false
                  }
              }
          }
          get '/' do
            present @task, with: V1::Entities::Task
          end
        end
      end
    end
  end
end