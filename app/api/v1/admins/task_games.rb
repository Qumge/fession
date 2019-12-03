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
                        when 'Game::Tiger'
                          Game::Tiger
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
          optional :type, type: String, desc: '游戏类型 Game::Wheel Game::Tiger Game::Scratch'
          optional :company_id, type: Integer, desc: '商户'
        end
        get '/' do
          company_id = @company.present? ? @company.id : params[:company_id]
          tasks = Task.joins(:game).where('tasks.company_id = ?', company_id)
          if params[:type].present?
            tasks = tasks.where('games.type = ?', params[:type])
          end
          present tasks, with: V1::Entities::Task
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
          requires :type, type: String, desc: '游戏类型 Game::Wheel Game::Tiger Game::Scratch'
          requires :name, type: String, desc: '游戏名'
          requires :coin, type: Integer, desc: '金币总数 用于转发任务'
          requires :game_coin, type: Integer, desc: '奖池金币总数'
          requires :valid_from, type: DateTime, desc: '有效期始'
          requires :valid_to, type: DateTime, desc: '有效至'
          optional :prizes, type: String, desc: '奖品 大转盘抽奖 默认为5个奖项 请勿多传或少传 [{product_id: 1, probability: 0.01, number: 1}, { coin: 200, probability: 0.01, number: 2}]', default:  [{product_id: 1, probability: 0.01, number: 1}, { coin: 200, probability: 0.01, number: 2}].to_json
        end
        post '/' do
          game = @game_model.new name: params[:name], coin: params[:game_coin], company: @company
          game = game.fetch_prizes JSON.parse(params[:prizes])
          if game.valid?
            task = Task::GameTask.create coin: params[:coin], valid_from: params[:valid_from], valid_to: params[:valid_to], game: game, company: @company
            present task, with: V1::Entities::Task
          else
            {error_code: '10001', error_messages: game.errors.messages}
          end
        end



        route_param :id do
          before do
            @task = Task.find_by company: @company, id: params[:id], company: @company
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
            optional :prizes, type: String, desc: '奖品 大转盘抽奖 默认为5个奖项 请勿多传或少传 [{product_id: 1, probability: 0.01, number: 1}, { coin: 200, probability: 0.01, number: 2}]', default:  [{product_id: 1, probability: 0.01, number: 1}, { coin: 200, probability: 0.01, number: 2}].to_json
          end
          patch '/' do
            game = @task.game
            game.attributes = {name: params[:name], coin: params[:game_coin], company: @company}
            game = game.fetch_prizes JSON.parse(params[:prizes])
            if game.valid?
              @task.update coin: params[:coin], valid_from: params[:valid_from], valid_to: params[:valid_to],  company: @company
              @task.do_recheck!
              present @task, with: V1::Entities::Task
            else
              {error_code: '10001', error_messages: game.errors.messages}
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
              {error_code: '20001', error_message: '删除失败'}
            else
              {error_code: '00000', error_message: '删除成功'}
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