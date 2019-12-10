module V1
  module Admins
    class TaskGames < Grape::API
      helpers V1::Admins::AdminLoginHelper
      include Grape::Kaminari
      #paginate per_page:  Settings.per_page, max_per_page: 9999, offset: 0
      before do
        authenticate!
      end

      resources 'task_game' do
        before do
          @game_model = case params[:type]
                        when 'Game::Wheel'
                          Game::Wheel
                        when 'Game::Egg'
                          Game::Egg
                        when 'Game::Scratch'
                          Game::Scratch
                        end
        end

        desc '商户游戏列表', {
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
          optional :type, type: String, desc: '游戏类型 Game::Wheel Game::Egg Game::Scratch'
          optional :company_id, type: Integer, desc: '商户'
          optional :status, type: String, desc: "状态 wait: '待审核', failed: '已拒绝', success: '审核成功' 数据库中只存储这三种状态 进行中和已经结束（active overtime）由有效时间和success组合而成 检索时使用（wait active overtime failed ）"
        end
        get '/' do
          tasks = Task::GameTask.joins(:game).all
          if params[:company_id].present?
            @company ||= Company.find_by id: params[:company_id]
          end
          #company_id = @company.present? ? @company.id : params[:company_id]
          if @company.present?
            tasks = tasks.where('tasks.company_id = ?', @company.id)
          end
          tasks = tasks.search_game_conn params
          present paginate(tasks), with: V1::Entities::Task
        end


        desc '商户创建游戏任务', {
            headers: {
                "X-Auth-Token" => {
                    description: "登录token",
                    required: false
                }
            }
        }
        params do
          requires :type, type: String, desc: '游戏类型 Game::Wheel Game::Egg Game::Scratch'
          requires :name, type: String, desc: '游戏名'
          requires :coin, type: Integer, desc: '金币总数 用于转发任务'
          requires :game_coin, type: Integer, desc: '奖池金币总数'
          requires :valid_from, type: DateTime, desc: '有效期始'
          requires :valid_to, type: DateTime, desc: '有效至'
          requires :image, type: String, desc: '背景图'
          requires :task_image, type: String, desc: '任务展示图'
          optional :desc, type: String, desc: '游戏说明'
          requires :prizes, type: String, desc: '奖品 大转盘抽奖 默认为5个奖项 请勿多传或少传 [{product_id: 1, probability: 0.01, number: 1}, { coin: 200, probability: 0.01, number: 2}]', default:  [{product_id: 1, probability: 0.01, number: 1}, { coin: 200, probability: 0.01, number: 2}].to_json
        end
        post '/' do
          image = Image.new file_path: params[:image], model_type: 'Game'
          task_image = Image.new file_path: params[:task_image], model_type: 'Task'
          game = @game_model.new name: params[:name], coin: params[:game_coin], company: @company, image: image, desc: params[:desc]
          game = game.fetch_prizes JSON.parse(params[:prizes])
          if game.valid?
            task = Task::GameTask.create coin: params[:coin], valid_from: params[:valid_from], valid_to: params[:valid_to], game: game, company: @company, image: task_image
            present task, with: V1::Entities::Task
          else
            {error: '10001', messages: game.errors.messages}
          end
        end



        route_param :id do
          before do
            if @company.present?
              @task = Task::GameTask.find_by id: params[:id], company: @company
            else
              @task = Task::GameTask.find_by id: params[:id]
            end
            error!("找不到数据", 500) unless @task.present?
          end

          desc '游戏任务变更', {
              headers: {
                  "X-Auth-Token" => {
                      description: "登录token",
                      required: false
                  }
              }
          }
          params do
            requires :name, type: String, desc: '游戏名'
            requires :coin, type: Integer, desc: '金币总数 用于转发任务'
            requires :game_coin, type: Integer, desc: '奖池金币总数'
            requires :valid_from, type: DateTime, desc: '有效期始'
            requires :valid_to, type: DateTime, desc: '有效至'
            requires :image, type: String, desc: '背景图'
            requires :task_image, type: String, desc: '任务展示图'
            optional :desc, type: String, desc: '游戏说明'
            optional :prizes, type: String, desc: '奖品 大转盘抽奖 默认为5个奖项 请勿多传或少传 [{product_id: 1, probability: 0.01, number: 1}, { coin: 200, probability: 0.01, number: 2}]', default:  [{product_id: 1, probability: 0.01, number: 1}, { coin: 200, probability: 0.01, number: 2}].to_json
          end
          patch '/' do
            image = Image.new file_path: params[:image], model_type: 'Game'
            task_image = Image.new file_path: params[:task_image], model_type: 'Task'
            game = @task.game
            game.image = image
            game.attributes = {name: params[:name], coin: params[:game_coin], company: @company, image: image, desc: params[:desc]}
            game = game.fetch_prizes JSON.parse(params[:prizes])
            if game.valid?
              @task.update coin: params[:coin], valid_from: params[:valid_from], valid_to: params[:valid_to],  company: @company, image: task_image
              #@task.do_recheck!
              @task.do_wait! if @task.may_do_wait?
              present @task, with: V1::Entities::Task
            else
              {error: '10001', messages: game.errors.messages}
            end
          end

          desc '删除游戏任务', {
              headers: {
                  "X-Auth-Token" => {
                      description: "登录token",
                      required: false
                  }
              }
          }
          delete '/' do
            if @task.failed? && @task.destroy
              {error: '20001', message: '删除失败'}
            else
              {error: '', message: '删除成功'}
            end
          end

          desc '任务详情', {
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