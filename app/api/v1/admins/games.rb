module V1
  module Admins
    class Games < Grape::API
      helpers V1::Admins::AdminLoginHelper
      before do
        authenticate!
        operator_auth!
      end

      resources 'games' do

        before do
          @game_model = case params[:type]
                        when 'Game::Wheel'
                          Game::Wheel
                        when 'Game::Tiger'
                          Game::Tiger
                        when 'Game::Egg'
                          Game::Egg
                        when 'Game::Scratch'
                          Game::Scratch
                        end
        end

        desc '创建变更平台游戏 平台每种游戏类型只有1个 存在就变更 不存在就创建', {
            headers: {
                "X-Auth-Token" => {
                    description: "登录token",
                    required: false
                }
            }
        }
        params do
          requires :type, type: String, desc: '游戏类型 Game::Wheel Game::Tiger Game::Egg'
          requires :name, type: String, desc: '游戏名'
          optional :cost, type: Integer, desc: '游戏消耗金币数  商户创建时不填'
          requires :prizes, type: String, desc: '奖品 大转盘抽奖 默认为5个奖项 请勿多传或少传 [{product_id: 1, probability: 0.01, number: 1}, { coin: 200, probability: 0.01, number: 2}]', default:  [{product_id: 1, probability: 0.01, number: 1}, { coin: 200, probability: 0.01, number: 2}].to_json
          requires :image, type: String, desc: '背景图片'
        end
        post '/' do
          image = Image.new file_path: params[:image], model_type: 'Game'
          game = @game_model.find_or_initialize_by company_id: nil
          game.attributes = {name: params[:name], cost: params[:cost], image: image}
          game = game.fetch_prizes JSON.parse(params[:prizes])
          if game.valid?
            present game, with: V1::Entities::Game
          else
            {error: '10001', messages: game.errors.messages&.values&.first&.first}
          end
        end

        desc '平台游戏详情', {
            headers: {
                "X-Auth-Token" => {
                    description: "登录token",
                    required: false
                }
            }
        }
        params do
          requires :type, type: String, desc: '游戏类型 Game::Wheel Game::Tiger Game::Scratch'
        end
        get 'show_game' do
          game = @game_model.find_by company_id: nil
          present game, with: V1::Entities::Game
        end

        desc '奖品管理', {
              headers: {
                  "X-Auth-Token" => {
                      description: "登录token",
                      required: false
                  }
              }
          }
        params do
          requires :type, type: String, desc: '游戏类型 Game::Wheel Game::Tiger Game::Scratch'
        end
        get 'prizes' do
          game = @game_model.find_by company_id: nil
          if game.present?
            prize_logs = game.prize_logs
            {number: prize_logs.size,
             coin: prize_logs.sum{|prize_log| prize_log.prize.type == 'Prize::CoinPrize' ? prize_log.prize.coin : 0},
             product_number: prize_logs.count{|prize_log| prize_log.prize.type == 'Prize::ProductPrize'}
            }
          else
            {number: '-',
            coin: '-',
            product_number: '-'
            }
          end
        end

        desc '中奖记录', {
            headers: {
                "X-Auth-Token" => {
                    description: "登录token",
                    required: false
                }
            }
        }
        params do
          requires :type, type: String, desc: '游戏类型 Game::Wheel Game::Tiger Game::Scratch'
        end
        get 'prize_logs' do
          game = @game_model.find_by company_id: nil
          if game.present?
            present game.prize_logs, with: V1::Entities::PrizeLog
          else
            []
          end
        end

        desc '平台游戏数据', {
            headers: {
                "X-Auth-Token" => {
                    description: "登录token",
                    required: false
                }
            }
        }
        params do
          requires :type, type: String, desc: '游戏类型 Game::Wheel Game::Tiger Game::Scratch'
          requires :date_from, type: String, desc: '游戏类型 Game::Wheel Game::Tiger Game::Scratch'
          requires :date_to, type: String, desc: '游戏类型 Game::Wheel Game::Tiger Game::Scratch'
        end
        get 'data' do
          date_from=DateTime.new.beginning_of_day
          date_to=DateTime.new.end_of_day
          if params[:date_from].present?
            date_from = params[:date_from].to_datetime
          end
          if params[:date_to].present?
            date_to = params[:date_to].to_datetime
          end
          game = @game_model.find_by company_id: nil
          if game.present?
            {
              view_number: game.game_view_logs.where(created_at: date_from..date_to).size,
              play_number: game.game_logs.where(created_at: date_from..date_to).size,
              play_coin: game.game_logs.where(created_at: date_from..date_to).sum(:coin),
              prize_number: game.prize_logs.where(created_at: date_from..date_to).size,
              prize_coin: game.prize_logs.left_joins(:prize).where(created_at: date_from..date_to).sum('prizes.coin'),
          }
          else
            {
              view_number: '-',
              play_number: '-',
              play_coin: '-',
              prize_number: '-',
              prize_coin: '-',
          }
          end
        end
      end
    end
  end
end