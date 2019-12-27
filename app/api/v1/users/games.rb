module V1
  module Users
    class Games < Grape::API
      helpers V1::Users::UserLoginHelper
      include Grape::Kaminari
      before do
        authenticate!
      end

      resources 'games' do
        desc '游戏列表', {
            headers: {
                "X-Auth-Token" => {
                    description: "登录token",
                    required: false
                }
            }
        }
        params do
          optional :type, type: String, desc: '游戏类型 Game::Wheel Game::Egg Game::Scratch'
        end
        get '/' do
          games = ::Game.where(company_id: nil)
          present games, with: V1::Entities::Game
        end

        route_param :id do
          before do
            @game = ::Game.find_by id: params[:id]
            error!("找不到数据", 500) unless @game.present?
          end
          desc '游戏详情'
          get '/' do
            present @game, with: V1::Entities::GameWithTask
          end

          desc '玩游戏'
          post 'play' do
            game_log =  @game.play @current_user
            if game_log[:error].present?
              game_log
            else
              present game_log, with: V1::Entities::GameLog
            end
          end
        end
      end
    end
  end
end