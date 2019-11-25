module V1
  module Admins
    class Admins < Grape::API
      helpers AdminLoginHelper
      resources 'admins' do
        desc '登录 登录成功将返回的authentication_token  之后请求时将 authentication_token写入header的 X-Auth-Token 里面'
        params do
          requires :login, type: String, desc: '登录账号'
          requires :password, type: String, desc: '密码'
        end
        post "/login" do
          @admin = Admin.find_by_login params[:login]

          if @admin.present?
            if @admin.locked?
              {error_code: '20002', error_message: '账号已冻结，不能登录，请联系管理员'}
            else
              if @admin.class.name == 'Customer'
                if @admin.company.present?
                  if @admin.company.locked?
                    {error_code: '20004', error_message: '商户已被冻结，请联系管理员'}
                  else
                    @admin.ensure_authentication_token!
                    {login: @admin.login, id: @admin.id, authentication_token: @admin.authentication_token, type: @admin.type, role_name: @admin.role&.name}
                  end
                else
                  {error_code: '20003', error_message: '错误的商户账号'}
                end
              else
                @admin.ensure_authentication_token!
                {login: @admin.login, id: @admin.id, authentication_token: @admin.authentication_token, type: @admin.type, role_name: @admin.role&.name}
              end
            end
          else
            {error_code: '20001', error_message: '账号或密码错误'}
          end
        end

      end
    end
  end

end