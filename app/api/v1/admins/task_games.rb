module V1
  module Admins
    class TaskGames < Grape::API
      helpers V1::Admins::AdminLoginHelper
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
        desc '商户创建大转盘任务', {
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
          optional :game_coin, type: Integer, desc: '奖池金币总数 平台创建时不填'
          requires :valid_from, type: DateTime, desc: '有效期始 平台创建时不填'
          requires :valid_to, type: DateTime, desc: '有效至 平台创建时不填'
          optional :prizes, type: Array[Hash], desc: '奖品 大转盘抽奖 默认为5个奖项 请勿多传或少传[{product_id: 1, probability: 0.01}, { coin: 200, probability: 0.1}, { coin: 500, probability: 0.05}, { coin: 1000, probability: 0.01}, { coin: 2000, probability: 0.005}]', default: [{product_id: 1, probability: 0.01}, { coin: 200, probability: 0.1}, { coin: 500, probability: 0.05}, { coin: 1000, probability: 0.01}, { coin: 2000, probability: 0.005}]
        end
        post '/' do
          game = @game_model.new name: params[:name], game_coin: params[:game_coin], company: @company
          game = game.fetch_prizes params[:prizes]
          if game.valid?
            task = Task::GameTask.create coin: params[:coin], valid_from: params[:valid_from], valid_to: params[:valid_to], game: game, company: @company
            present task, with: V1::Entities::Task
          else
            {error_code: '10001', error_messages: game.errors.messages}
          end
        end



        route_param :id do
          before do
            @task = @company.tasks.find_by id: params[:id]
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
            requires :product_id, type: Integer, desc: '产品id'
            requires :coin, type: Integer, desc: '金币总数'
            requires :valid_from, type: DateTime, desc: '有效期始'
            requires :valid_to, type: DateTime, desc: '有效至'
          end
          patch '/' do
            game = @task.game
            article = @task.article
            article.attributes = {prodcut_id: params[:product_id], company: @company, subject: params[:subject], content: params[:content]}
            if @task.update article: article, coin: params[:coin], valid_from: params[:valid_from], valid_to: params[:valid_to], company: @company
              present @task, with: V1::Entities::Task
            else
              {code: '100001', error_message: @task.errors}
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