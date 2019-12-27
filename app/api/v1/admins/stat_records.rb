module V1
  module Admins
    class StatRecords < Grape::API
      helpers V1::Admins::AdminLoginHelper
      include Grape::Kaminari
      before do
        authenticate!
      end

      resources 'stat_records' do
        desc '数据统计', {
            headers: {
                "X-Auth-Token" => {
                    description: "登录token 运营平台账号",
                    required: false
                }
            }
        }
        params do
          optional :type, type: String, desc: "状态 Task::QuestionnaireTask Task::ArticleTask Task::LinkTask Task::ProductTask Task::GameTask"
          optional :game_type, type: String, desc: '游戏类型  Game::Wheel Game::Tiger Game::Scratch Game::egg'
          optional :date_from, type: String, desc: '起始时间'
          optional :date_to, type: String, desc: '结束时间'
          optional :task_id, type: String, desc: '任务id'
          optional :game_id, type: Integer, desc: '游戏id'
          optional :company_id, type: Integer, desc: '商户id'
          optional :page, type: String, desc: '页码'
          optional :per_page, type: Integer, desc: '每页数据个数', default: Settings.per_page
        end
        get '/' do
          if @company.present?
            params[:company_id] = @company.id
          end
          total_data, date_headers, chart_data, table_data = Record.data params
          {total_data: total_data, date_headers: date_headers, chart_data: chart_data, table_data: paginate(Kaminari.paginate_array(table_data.to_a))}
        end


        desc '交易数据', {
            headers: {
                "X-Auth-Token" => {
                    description: "登录token 运营平台账号",
                    required: false
                }
            }
        }
        params do
          optional :date_from, type: String, desc: '起始时间'
          optional :date_to, type: String, desc: '结束时间'
          optional :company_id, type: Integer, desc: '商户id'
          optional :page, type: String, desc: '页码'
          optional :per_page, type: Integer, desc: '每页数据个数', default: Settings.per_page
        end
        get 'orders' do
          if @company.present?
            params[:company_id] = @company.id
          end
          total_data, date_headers, chart_data, table_data = SaleData.new(params).data
          {total_data: total_data, date_headers: date_headers, chart_data: chart_data, table_data: paginate(Kaminari.paginate_array(table_data.to_a))}
        end

        desc '首页待办任务', {
            headers: {
                "X-Auth-Token" => {
                    description: "登录token 运营平台账号",
                    required: false
                }
            }
        }
        get 'tasks' do
          if @company.present?
            wait_order = ::Order.where(status: 'pay', company_id: @company.id)
            after_sale_order = ::Order.where(status: 'pay', company_id: @company.id)
            sale_out = ::Norm.where(stock: 0)
            {wait_order: wait_order.size, after_sale_order: after_sale_order.size, sale_out: sale_out.size}
          else
            wait_product = ::Product.where(status: 'wait')
            wait_post = ::Post.where(status: 'wait')
            wait_cash = ::Cash.where(status: 'wait')
            wait_order = ::Order.where(status: 'pay')
            after_sale_order = ::Order.where(status: 'pay')

            wait_product_task = Task::ProductTask.where(status: 'wait')
            wait_game_task = Task::GameTask.where(status: 'wait')
            wait_questionnaire_task = Task::QuestionnaireTask.where(status: 'wait')
            wait_article_task = Task::ArticleTask.where(status: 'wait')

            {
                wait_product: wait_product.size, wait_post: wait_post.size, wait_cash: wait_cash.size, wait_order: wait_order.size,
                after_sale_order: after_sale_order.size, wait_product_task: wait_product_task.size, wait_game_task: wait_game_task.size,
                wait_questionnaire_task: wait_questionnaire_task.size, wait_article_task: wait_article_task.size
            }
          end
        end
      end

    end
  end
end
