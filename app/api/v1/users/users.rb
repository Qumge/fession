module V1
  module Users
    class Users < Grape::API
      helpers UserLoginHelper
      resources 'users' do
        desc '登录 登录成功将返回的authentication_token  之后请求时将 authentication_token写入header的 X-Auth-Token 里面'
        params do
          requires :login, type: String, desc: '登录账号'
          requires :code, type: String, desc: '验证码'
        end
        post "/login" do
          @user = User.find_by_login params[:login]
          if @user && @user[:locked]
            {error_code: '20009', error_message: '账号被锁定'}
          elsif @user && !@user[:locked] && (@user.code_create_at + 5.minutes) > DateTime.now
            #sign_in @admin
            @user.ensure_authentication_token!
            {login: @user.login, id: @user.id, authentication_token: @user.authentication_token}
          else
            {error_code: '20001', error_message: '验证码错误或超时'}
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
          else
            {error_code: '20002', error_message: '手机号码有误'}
          end
        end


      end
    end
  end

end