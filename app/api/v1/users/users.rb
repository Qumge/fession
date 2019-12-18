module V1
  module Users
    class Users < Grape::API
      helpers UserLoginHelper
      helpers QiniuHelper
      include Grape::Kaminari
      resources 'users' do
        desc '登录 登录成功将返回的authentication_token  之后请求时将 authentication_token写入header的 X-Auth-Token 里面'
        params do
          requires :login, type: String, desc: '登录账号'
          requires :code, type: String, desc: '验证码'
        end
        post "/login" do
          @user = User.find_by_login params[:login]
          if @user && @user[:locked]
            {error: '20009', message: '账号被锁定'}
          elsif @user && !@user[:locked] && (@user.code_create_at + 5.minutes) > DateTime.now
            #sign_in @admin
            @user.ensure_authentication_token!
            {login: @user.login, id: @user.id, authentication_token: @user.authentication_token}
          else
            {error: '20001', message: '验证码错误或超时'}
          end
        end


        desc '公众号登录'
        params do
          requires :code, type: String, desc: '微信code'
          optional :type, type: String, desc: '公众号：default， 安卓ios： app ', default: 'default'
        end
        post "/wx_login" do
          user = User.init_by_web_code params[:code], params[:type]
          if user.present? && user.is_a?(User)
            {authentication_token: user.authentication_token}
          end
        end


        desc '通过手机号注册、登录'
        params do
          requires :login, type: String, desc: '手机号码'
        end
        post "get_code" do
          user = User.find_or_initialize_by login: params[:login]
          if user.valid?
            user.send_code_sms
            present user, with: V1::Entities::User
          else
            {error: '20002', message: '手机号码有误'}
          end
        end

        before do
          authenticate!
        end


        desc '个人详情 follower：关注我的  follow_companies: 我关注的店铺 follow_users: 我关注的用户 coin：金币数', {
            headers: {
                "X-Auth-Token" => {
                    description: "登录token",
                    required: false
                }
            }
        }
        get 'me' do
          present @current_user, with: V1::Entities::Account
        end


        desc '个人信息变更', {
            headers: {
                "X-Auth-Token" => {
                    description: "登录token",
                    required: false
                }
            }
        }

        params do
          optional :nick_name, type: String, desc: '昵称'
          optional :login, type: String, desc: '手机号  登录账号'
          optional :desc, type: String, desc: '个性签名'
          optional :avatar_url, type: String, desc: '头像'
        end
        post 'profile' do
          @current_user.fetch_params params
          if @current_user.save
            present @current_user, with: V1::Entities::User
          end
        end

        desc '我关注的商户', {
            headers: {
                "X-Auth-Token" => {
                    description: "登录token",
                    required: false
                }
            }
        }
        params do
          optional :search, type: String, desc: '检索内容'
          optional :page,     type: Integer, default: 1, desc: '页码'
          optional :per_page, type: Integer, desc: '每页数据个数', default: Settings.per_page
        end
        get 'follow_companies' do
          present paginate(@current_user.follow_companies.search_conn(params)), with: V1::Entities::Company
        end

        desc '我关注的用户', {
            headers: {
                "X-Auth-Token" => {
                    description: "登录token",
                    required: false
                }
            }
        }
        params do
          optional :search, type: String, desc: '检索内容'
          optional :page,     type: Integer, default: 1, desc: '页码'
          optional :per_page, type: Integer, desc: '每页数据个数', default: Settings.per_page
        end
        get 'follow_users' do
          present paginate(@current_user.follow_users.search_conn(params)), with: V1::Entities::User
        end

        desc '我的任务', {
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
        end
        get 'tasks' do
          present paginate(@current_user.fission_logs), with: V1::Entities::FissionLog
        end


        desc '关注我的人', {
            headers: {
                "X-Auth-Token" => {
                    description: "登录token",
                    required: false
                }
            }
        }
        params do
          optional :search, type: String, desc: '检索内容'
          optional :page,     type: Integer, default: 1, desc: '页码'
          optional :per_page, type: Integer, desc: '每页数据个数', default: Settings.per_page
        end
        get 'followers' do
          present paginate(@current_user.followers.search_conn(params)), with: V1::Entities::User, user: current_user
        end

        desc '我的金币流水', {
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
          optional :type, type: String, desc: '流水流入流出 in out'
        end
        get 'coin_logs' do
          present paginate(@current_user.coin_logs.search_conn params), with: V1::Entities::CoinLog
        end

        desc '关注用户', {
            headers: {
                "X-Auth-Token" => {
                    description: "登录token",
                    required: false
                }
            }
        }
        params do
          requires :user_id,     type: Integer,  desc: '关注的人id'
        end
        post 'follow_user' do
          user = User.find_by id: params[:user_id]
          if user.present?
            @current_user.follow_users << user unless @current_user.follow_users.include?(user)
            {error: '', message: '关注成功'}
            #present @current_user.reload, with: V1::Entities::User
          else
            {error: '20002', message: '错误的用户'}
          end
        end

        desc '取消关注用户', {
            headers: {
                "X-Auth-Token" => {
                    description: "登录token",
                    required: false
                }
            }
        }
        params do
          requires :user_id,     type: Integer,  desc: '关注的人id'
        end
        post 'unfollow_user' do
          user = User.find_by id: params[:user_id]
          if user.present?
            @current_user.follow_users.delete user
            #present @current_user.reload, with: V1::Entities::User
            {error: '', message: '取消关注成功'}
          else
            {error: '20002', message: '错误的用户'}
          end
        end


        desc '关注商户', {
            headers: {
                "X-Auth-Token" => {
                    description: "登录token",
                    required: false
                }
            }
        }
        params do
          requires :company_id,     type: Integer,  desc: '关注的商户id'
        end
        post 'follow_company' do
          company = Company.find_by id: params[:company_id]
          if company.present?
            @current_user.follow_companies << company unless @current_user.follow_companies.include?(company)
            {error: '', message: '关注成功'}
            #present @current_user.reload, with: V1::Entities::User
          else
            {error: '20002', message: '错误的商户'}
          end
        end

        desc '取消关注商户', {
            headers: {
                "X-Auth-Token" => {
                    description: "登录token",
                    required: false
                }
            }
        }
        params do
          requires :company_id,     type: Integer,  desc: '关注的商户id'
        end
        post 'unfollow_company' do
          company = Company.find_by id: params[:company_id]
          if company.present?
            @current_user.follow_companies.delete company
            {error: '', message: '取消关注成功'}
            #present @current_user.reload, with: V1::Entities::User
          else
            {error: '20002', message: '错误的商户'}
          end
        end

        desc '提现', {
            headers: {
                "X-Auth-Token" => {
                    description: "登录token",
                    required: false
                }
            }
        }
        params do
          requires :amount,     type: Integer,  desc: '金钱单位（元） 需要大于提现规则'
        end
        post 'cash' do
          cash = @current_user.cashes.new
          cash = cash.fetch_params params
          if cash.errors.present?
            {error: '30001', message: cash.errors.messages}
          else
            present cash, with: V1::Entities::Cash
          end
        end

        desc '玩游戏', {
            headers: {
                "X-Auth-Token" => {
                    description: "登录token",
                    required: false
                }
            }
        }
        params do
          requires :id,     type: Integer,  desc: '游戏id'
        end
        post 'play_game' do
          game = Game.find_by params[:id]
          if game.present?
            game.play @current_user
          else
            error!('找不到数据', 500)
          end
        end


      end
    end
  end

end