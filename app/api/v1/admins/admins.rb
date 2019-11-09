module V1
  module Admins
    class Admins < Grape::API
      resources 'admins' do
        desc '登录 登录成功将返回的authentication_token  之后请求时将 authentication_token写入header的 Admin_Authentication_Token 里面'
        params do
          requires :login, type: String, desc: '登录账号'
          requires :password, type: String, desc: '登录账号'
        end
        post "/login" do
          @admin = Admin.find_by_login params[:login]
          if @admin && @admin[:locked]
            {error_code: '20009', error_message: '账号被锁定'}
          elsif @admin && !@admin[:locked] && @admin.valid_password?(params[:password])
            #sign_in @admin
            @admin.ensure_authentication_token!
            {admins: {login: @admin.login, authentication_token: @admin.authentication_token type: @admin.type}}
          else
            {error: '20001', error_message: '账号或密码错误'}
          end
        end

        before do
          authenticate!
        end
        get 'index' do
          p 1111
        end
      end
    end
  end

end