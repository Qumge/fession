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
      end

    end
  end
end
