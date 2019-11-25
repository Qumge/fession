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
          requires :type, type: String, desc: '游戏类型 Game::Wheel Game::Tiger Game::Scratch'
          requires :name, type: String, desc: '游戏名'
          optional :cost, type: Integer, desc: '游戏消耗金币数  商户创建时不填'
          optional :prizes, type: String, desc: '奖品 大转盘抽奖 默认为5个奖项 请勿多传或少传 [{product_id: 1, probability: 0.01, number: 1}, { coin: 200, probability: 0.01, number: 2}]', default:  [{product_id: 1, probability: 0.01, number: 1}, { coin: 200, probability: 0.01, number: 2}]
        end
        post '/' do
          game = @game_model.find_or_initialize_by company_id: nil
          game.attributes = {name: params[:name], cost: params[:cost]}
          game = game.fetch_prizes JSON.parse(params[:prizes])
          if game.valid?
            present game, with: V1::Entities::Game
          else
            {error_code: '10001', error_messages: game.errors.messages}
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


      end
    end
  end
end